use crate::{config::{normalize_system_prompt, EngineConfig}, model_profile::ModelProfileConfig};
use serde::{Deserialize, Serialize};
use std::{sync::Arc, time::{SystemTime, UNIX_EPOCH}};
use tokio::sync::RwLock;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum RuntimeStage {
    Idle,
    Preparing,
    Completed,
    Error,
}

impl Default for RuntimeStage {
    fn default() -> Self {
        Self::Idle
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct RuntimeSnapshot {
    pub stage: RuntimeStage,
    pub model_loaded: bool,
    pub active_model_profile_id: Option<String>,
    pub total_requests: u64,
    pub last_event: Option<String>,
    pub last_error: Option<String>,
    pub last_request_epoch_seconds: Option<u64>,
    pub last_system_prompt_chars: Option<usize>,
    pub last_system_prompt_preview: Option<String>,
}

#[derive(Clone, Default)]
pub struct RuntimeManager {
    state: Arc<RwLock<RuntimeSnapshot>>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct RuntimeChatRequest {
    pub prompt: String,
    #[serde(default)]
    pub system_prompt: Option<String>,
    #[serde(default)]
    pub model_profile: Option<ModelProfileConfig>,
}

#[derive(Debug, Clone, Serialize)]
pub struct RuntimeChatResponse {
    pub accepted: bool,
    pub model_started: bool,
    pub model_stopped_after_response: bool,
    pub model_loaded: bool,
    pub stage: RuntimeStage,
    pub active_model_profile_id: Option<String>,
    pub system_prompt_applied: bool,
    pub system_prompt_chars: usize,
    pub system_prompt_preview: String,
    pub generated_text: Option<String>,
    pub message: String,
}

impl RuntimeManager {
    pub async fn snapshot(&self) -> RuntimeSnapshot {
        self.state.read().await.clone()
    }

    pub async fn prepare_chat(
        &self,
        config: &EngineConfig,
        request: RuntimeChatRequest,
    ) -> RuntimeChatResponse {
        let resolved_system_prompt = request
            .system_prompt
            .as_ref()
            .map(|value| normalize_system_prompt(value.clone()))
            .unwrap_or_else(|| normalize_system_prompt(config.system_prompt.clone()));

        let system_prompt_chars = resolved_system_prompt.chars().count();
        let system_prompt_preview = preview_text(&resolved_system_prompt, 120);

        if !config.local_model_enabled {
            let message = "local model mode is disabled; no model was started".to_string();
            self.mark_error(
                message.clone(),
                config.active_model_profile_id.clone(),
                Some(&resolved_system_prompt),
            )
            .await;

            return self.response(
                false,
                false,
                false,
                false,
                RuntimeStage::Error,
                config.active_model_profile_id.clone(),
                system_prompt_chars,
                system_prompt_preview,
                message,
            );
        }

        if !config.auto_start_on_message {
            let message = "auto start on message is disabled; no model was started".to_string();
            self.mark_error(
                message.clone(),
                config.active_model_profile_id.clone(),
                Some(&resolved_system_prompt),
            )
            .await;

            return self.response(
                false,
                false,
                false,
                false,
                RuntimeStage::Error,
                config.active_model_profile_id.clone(),
                system_prompt_chars,
                system_prompt_preview,
                message,
            );
        }

        if request.prompt.trim().is_empty() {
            let message = "prompt is empty; no model was started".to_string();
            self.mark_error(
                message.clone(),
                config.active_model_profile_id.clone(),
                Some(&resolved_system_prompt),
            )
            .await;

            return self.response(
                false,
                false,
                false,
                false,
                RuntimeStage::Error,
                config.active_model_profile_id.clone(),
                system_prompt_chars,
                system_prompt_preview,
                message,
            );
        }

        let profile = request
            .model_profile
            .or_else(|| config.active_model_profile.clone())
            .map(ModelProfileConfig::normalized);

        let Some(profile) = profile else {
            let message = "no active model profile is configured; no model was started".to_string();
            self.mark_error(
                message.clone(),
                config.active_model_profile_id.clone(),
                Some(&resolved_system_prompt),
            )
            .await;

            return self.response(
                false,
                false,
                false,
                false,
                RuntimeStage::Error,
                config.active_model_profile_id.clone(),
                system_prompt_chars,
                system_prompt_preview,
                message,
            );
        };

        if !profile.has_model_path() {
            let message = "active model profile has no model_path; no model was started".to_string();
            self.mark_error(message.clone(), Some(profile.id.clone()), Some(&resolved_system_prompt))
                .await;

            return self.response(
                false,
                false,
                false,
                false,
                RuntimeStage::Error,
                Some(profile.id),
                system_prompt_chars,
                system_prompt_preview,
                message,
            );
        }

        self.mark_preparing(Some(profile.id.clone()), &resolved_system_prompt)
            .await;

        let should_unload = config.unload_after_response || !config.keep_model_loaded;
        let final_model_loaded = !should_unload && config.allow_background_model;

        self.mark_completed(Some(profile.id.clone()), final_model_loaded, &resolved_system_prompt)
            .await;

        self.response(
            true,
            true,
            !final_model_loaded,
            final_model_loaded,
            RuntimeStage::Completed,
            Some(profile.id),
            system_prompt_chars,
            system_prompt_preview,
            "runtime lifecycle is ready; actual GGUF execution adapter is not connected in this step".to_string(),
        )
    }

    fn response(
        &self,
        accepted: bool,
        model_started: bool,
        model_stopped_after_response: bool,
        model_loaded: bool,
        stage: RuntimeStage,
        active_model_profile_id: Option<String>,
        system_prompt_chars: usize,
        system_prompt_preview: String,
        message: String,
    ) -> RuntimeChatResponse {
        RuntimeChatResponse {
            accepted,
            model_started,
            model_stopped_after_response,
            model_loaded,
            stage,
            active_model_profile_id,
            system_prompt_applied: system_prompt_chars > 0,
            system_prompt_chars,
            system_prompt_preview,
            generated_text: None,
            message,
        }
    }

    pub async fn unload(&self) -> RuntimeSnapshot {
        let mut state = self.state.write().await;
        state.stage = RuntimeStage::Idle;
        state.model_loaded = false;
        state.last_event = Some("model_unloaded".to_string());
        state.last_error = None;
        state.clone()
    }

    async fn mark_preparing(&self, profile_id: Option<String>, system_prompt: &str) {
        let mut state = self.state.write().await;
        state.stage = RuntimeStage::Preparing;
        state.model_loaded = true;
        state.active_model_profile_id = profile_id;
        state.total_requests = state.total_requests.saturating_add(1);
        state.last_event = Some("runtime_request_started".to_string());
        state.last_error = None;
        state.last_request_epoch_seconds = Some(now_epoch_seconds());
        state.last_system_prompt_chars = Some(system_prompt.chars().count());
        state.last_system_prompt_preview = Some(preview_text(system_prompt, 120));
    }

    async fn mark_completed(&self, profile_id: Option<String>, model_loaded: bool, system_prompt: &str) {
        let mut state = self.state.write().await;
        state.stage = RuntimeStage::Completed;
        state.model_loaded = model_loaded;
        state.active_model_profile_id = profile_id;
        state.last_event = Some(if model_loaded {
            "runtime_request_completed_keep_loaded".to_string()
        } else {
            "runtime_request_completed_unloaded".to_string()
        });
        state.last_error = None;
        state.last_system_prompt_chars = Some(system_prompt.chars().count());
        state.last_system_prompt_preview = Some(preview_text(system_prompt, 120));
    }

    async fn mark_error(&self, error: String, profile_id: Option<String>, system_prompt: Option<&str>) {
        let mut state = self.state.write().await;
        state.stage = RuntimeStage::Error;
        state.model_loaded = false;
        state.active_model_profile_id = profile_id;
        state.last_event = Some("runtime_request_rejected".to_string());
        state.last_error = Some(error);
        state.last_request_epoch_seconds = Some(now_epoch_seconds());
        if let Some(system_prompt) = system_prompt {
            state.last_system_prompt_chars = Some(system_prompt.chars().count());
            state.last_system_prompt_preview = Some(preview_text(system_prompt, 120));
        }
    }
}

fn preview_text(value: &str, max_chars: usize) -> String {
    let normalized = value.split_whitespace().collect::<Vec<_>>().join(" ");
    let mut preview: String = normalized.chars().take(max_chars).collect();

    if normalized.chars().count() > max_chars {
        preview.push_str("...");
    }

    preview
}

fn now_epoch_seconds() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_secs())
        .unwrap_or_default()
}
