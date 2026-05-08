use crate::{config::EngineConfig, model_profile::ModelProfileConfig};
use axum::response::sse::Event;
use futures_util::StreamExt;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::{
    convert::Infallible,
    env,
    path::Path,
    process::Stdio,
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc,
    },
    time::{SystemTime, UNIX_EPOCH},
};
use tokio::{
    process::{Child, Command},
    sync::{mpsc, Mutex, RwLock},
    time::{sleep, Duration, Instant},
};
use tokio_stream::wrappers::ReceiverStream;

const DEFAULT_LLAMA_SERVER_BIN: &str = "llama-server";
const DEFAULT_LLAMA_SERVER_HOST: &str = "127.0.0.1";
const DEFAULT_LLAMA_SERVER_PORT: u16 = 8788;
const STARTUP_TIMEOUT_SECONDS: u64 = 60;
const LLAMA_SERVER_MAINTENANCE_MESSAGE: &str = "llama_server_bin_not_found: runtime_in_maintenance_until_llama_server_is_installed_or_LOGIXA_LLAMA_SERVER_BIN_is_configured";

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum RuntimeStage {
    Idle,
    Starting,
    Ready,
    Generating,
    Stopping,
    Stopped,
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
    pub last_system_prompt_chars: usize,
    pub last_system_prompt_preview: Option<String>,
    pub server_url: Option<String>,
}

#[derive(Clone)]
pub struct RuntimeManager {
    state: Arc<RwLock<RuntimeSnapshot>>,
    llama_server_child: Arc<Mutex<Option<Child>>>,
    stop_requested: Arc<AtomicBool>,
    client: Client,
    server_url: String,
}

impl Default for RuntimeManager {
    fn default() -> Self {
        let server_url = runtime_server_url();
        Self {
            state: Arc::new(RwLock::new(RuntimeSnapshot {
                server_url: Some(server_url.clone()),
                ..RuntimeSnapshot::default()
            })),
            llama_server_child: Arc::new(Mutex::new(None)),
            stop_requested: Arc::new(AtomicBool::new(false)),
            client: Client::builder()
                .timeout(Duration::from_secs(120))
                .build()
                .unwrap_or_else(|_| Client::new()),
            server_url,
        }
    }
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
    pub generated_text: Option<String>,
    pub reasoning_text: Option<String>,
    pub message: String,
    pub system_prompt_applied: bool,
    pub system_prompt_chars: usize,
    pub system_prompt_preview: Option<String>,
    pub server_url: Option<String>,
}

pub type RuntimeSseStream = ReceiverStream<Result<Event, Infallible>>;

#[derive(Debug, Clone, Default)]
struct RuntimeGeneratedText {
    visible_text: String,
    reasoning_text: Option<String>,
}

impl RuntimeManager {
    pub async fn snapshot(&self) -> RuntimeSnapshot {
        self.state.read().await.clone()
    }

    pub async fn prepare_chat(
        &self,
        config: &EngineConfig,
        payload: RuntimeChatRequest,
    ) -> RuntimeChatResponse {
        let prompt = payload.prompt.trim().to_string();
        let profile = match self.resolve_profile(config, payload.model_profile) {
            Ok(profile) => profile,
            Err(message) => return self.reject(message).await,
        };

        if !config.local_model_enabled {
            return self.reject("local_model_disabled".to_string()).await;
        }

        if !config.auto_start_on_message {
            return self
                .reject("auto_start_on_message_disabled".to_string())
                .await;
        }

        if prompt.is_empty() {
            return self.reject("empty_prompt".to_string()).await;
        }

        if !profile.has_model_path() {
            return self
                .reject_for_profile(profile.id.clone(), "missing_model_path".to_string())
                .await;
        }

        if !Path::new(&profile.model_path).is_absolute() {
            return self
                .reject_for_profile(
                    profile.id.clone(),
                    format!("model_path_must_be_absolute: {}", profile.model_path),
                )
                .await;
        }
        if !Path::new(&profile.model_path).is_file() {
            return self
                .reject_for_profile(
                    profile.id.clone(),
                    format!("model_path_not_found: {}", profile.model_path),
                )
                .await;
        }

        if let Err(message) = validate_llama_server_bin() {
            return self.reject_for_profile(profile.id.clone(), message).await;
        }

        let system_prompt = resolve_system_prompt(config, payload.system_prompt);
        let system_prompt_chars = system_prompt
            .as_deref()
            .map(|value| value.chars().count())
            .unwrap_or_default();
        let system_prompt_preview = system_prompt
            .as_deref()
            .map(|value| preview_text(value, 160))
            .filter(|value| !value.is_empty());
        let system_prompt_applied = system_prompt_chars > 0;

        self.update_state(|state| {
            state.stage = RuntimeStage::Starting;
            state.model_loaded = false;
            state.active_model_profile_id = Some(profile.id.clone());
            state.total_requests = state.total_requests.saturating_add(1);
            state.last_event = Some("starting_llama_server".to_string());
            state.last_error = None;
            state.last_request_epoch_seconds = Some(now_epoch_seconds());
            state.last_system_prompt_chars = system_prompt_chars;
            state.last_system_prompt_preview = system_prompt_preview.clone();
            state.server_url = Some(self.server_url.clone());
        })
        .await;

        let model_started = match self.ensure_llama_server_ready(&profile).await {
            Ok(started) => started,
            Err(message) => {
                return self
                    .fail(
                        profile.id.clone(),
                        message,
                        system_prompt_applied,
                        system_prompt_chars,
                        system_prompt_preview.clone(),
                    )
                    .await
            }
        };

        self.update_state(|state| {
            state.stage = RuntimeStage::Generating;
            state.model_loaded = true;
            state.last_event = Some("generating".to_string());
            state.last_error = None;
        })
        .await;

        let generated_text = match self
            .send_chat_completion(&profile, system_prompt.as_deref(), &prompt)
            .await
        {
            Ok(text) => text,
            Err(message) => {
                return self
                    .fail(
                        profile.id.clone(),
                        message,
                        system_prompt_applied,
                        system_prompt_chars,
                        system_prompt_preview.clone(),
                    )
                    .await
            }
        };

        let mut stopped_after_response = false;
        if config.unload_after_response && !config.keep_model_loaded {
            stopped_after_response = true;
            let _ = self.stop_llama_server().await;
        }

        let snapshot = self
            .update_state(|state| {
                state.stage = RuntimeStage::Completed;
                state.model_loaded = !stopped_after_response;
                state.active_model_profile_id = Some(profile.id.clone());
                state.last_event = Some(if stopped_after_response {
                    "completed_and_unloaded".to_string()
                } else {
                    "completed_keep_loaded".to_string()
                });
                state.last_error = None;
                state.server_url = Some(self.server_url.clone());
            })
            .await;

        RuntimeChatResponse {
            accepted: true,
            model_started,
            model_stopped_after_response: stopped_after_response,
            model_loaded: snapshot.model_loaded,
            stage: snapshot.stage,
            active_model_profile_id: snapshot.active_model_profile_id,
            generated_text: Some(generated_text),
            reasoning_text: None,
            message: if stopped_after_response {
                "llama-server response completed and runtime unloaded".to_string()
            } else {
                "llama-server response completed and runtime kept loaded".to_string()
            },
            system_prompt_applied,
            system_prompt_chars,
            system_prompt_preview,
            server_url: Some(self.server_url.clone()),
        }
    }

    pub async fn unload(&self) -> RuntimeSnapshot {
        self.update_state(|state| {
            state.stage = RuntimeStage::Stopping;
            state.last_event = Some("manual_unload_requested".to_string());
        })
        .await;

        let _ = self.stop_llama_server().await;

        self.update_state(|state| {
            state.stage = RuntimeStage::Stopped;
            state.model_loaded = false;
            state.last_event = Some("manual_unload_completed".to_string());
            state.last_error = None;
        })
        .await
    }

    fn resolve_profile(
        &self,
        config: &EngineConfig,
        override_profile: Option<ModelProfileConfig>,
    ) -> Result<ModelProfileConfig, String> {
        override_profile
            .or_else(|| config.active_model_profile.clone())
            .map(ModelProfileConfig::normalized)
            .ok_or_else(|| "missing_active_model_profile".to_string())
    }

    async fn ensure_llama_server_ready(
        &self,
        profile: &ModelProfileConfig,
    ) -> Result<bool, String> {
        if self.is_llama_server_healthy().await {
            self.update_state(|state| {
                state.stage = RuntimeStage::Ready;
                state.model_loaded = true;
                state.last_event = Some("llama_server_already_ready".to_string());
            })
            .await;
            return Ok(false);
        }

        let mut child_guard = self.llama_server_child.lock().await;
        if child_guard.is_none() {
            let child = spawn_llama_server(profile)
                .map_err(|error| format!("llama_server_spawn_failed: {error}"))?;
            *child_guard = Some(child);
        }
        drop(child_guard);

        let deadline = Instant::now() + Duration::from_secs(STARTUP_TIMEOUT_SECONDS);
        while Instant::now() < deadline {
            if self.is_llama_server_healthy().await {
                self.update_state(|state| {
                    state.stage = RuntimeStage::Ready;
                    state.model_loaded = true;
                    state.last_event = Some("llama_server_ready".to_string());
                    state.last_error = None;
                })
                .await;
                return Ok(true);
            }
            sleep(Duration::from_millis(500)).await;
        }

        Err(format!(
            "startup_timeout: llama-server did not become ready within {STARTUP_TIMEOUT_SECONDS}s"
        ))
    }

    async fn is_llama_server_healthy(&self) -> bool {
        match self
            .client
            .get(format!("{}/health", self.server_url))
            .send()
            .await
        {
            Ok(response) => response.status().is_success(),
            Err(_) => false,
        }
    }

    async fn send_chat_completion(
        &self,
        profile: &ModelProfileConfig,
        system_prompt: Option<&str>,
        user_prompt: &str,
    ) -> Result<String, String> {
        let messages = build_chat_messages(profile, system_prompt, user_prompt);
        let body = build_chat_completion_body(profile, false, messages);

        let response = self
            .client
            .post(format!("{}/v1/chat/completions", self.server_url))
            .json(&body)
            .send()
            .await
            .map_err(|error| format!("request_timeout_or_connection_error: {error}"))?;

        let status = response.status();
        let value = response
            .json::<Value>()
            .await
            .map_err(|error| format!("invalid_llama_server_json: {error}"))?;

        if !status.is_success() {
            return Err(format!("llama_server_http_{}: {value}", status.as_u16()));
        }

        extract_generated_text(&value).ok_or_else(|| format!("missing_generated_text: {value}"))
    }

    pub async fn prepare_chat_stream(
        &self,
        config: EngineConfig,
        payload: RuntimeChatRequest,
    ) -> RuntimeSseStream {
        let (sender, receiver) = mpsc::channel(128);
        let runtime = self.clone();
        tokio::spawn(async move {
            runtime.run_chat_stream(config, payload, sender).await;
        });
        ReceiverStream::new(receiver)
    }

    pub async fn stop_generation(&self) -> RuntimeSnapshot {
        self.stop_requested.store(true, Ordering::SeqCst);
        let _ = self.stop_llama_server().await;
        self.update_state(|state| {
            state.stage = RuntimeStage::Stopped;
            state.model_loaded = false;
            state.last_event = Some("generation_stopped_by_user".to_string());
            state.last_error = None;
            state.server_url = Some(self.server_url.clone());
        })
        .await
    }

    async fn run_chat_stream(
        &self,
        config: EngineConfig,
        payload: RuntimeChatRequest,
        sender: mpsc::Sender<Result<Event, Infallible>>,
    ) {
        self.stop_requested.store(false, Ordering::SeqCst);

        let prompt = payload.prompt.trim().to_string();
        let profile = match self.resolve_profile(&config, payload.model_profile) {
            Ok(profile) => profile,
            Err(message) => {
                let response = self.reject(message).await;
                send_stream_event(&sender, "error", json!(response)).await;
                return;
            }
        };

        if !config.local_model_enabled {
            let response = self.reject("local_model_disabled".to_string()).await;
            send_stream_event(&sender, "error", json!(response)).await;
            return;
        }

        if !config.auto_start_on_message {
            let response = self
                .reject("auto_start_on_message_disabled".to_string())
                .await;
            send_stream_event(&sender, "error", json!(response)).await;
            return;
        }

        if prompt.is_empty() {
            let response = self.reject("empty_prompt".to_string()).await;
            send_stream_event(&sender, "error", json!(response)).await;
            return;
        }

        if !profile.has_model_path() {
            let response = self
                .reject_for_profile(profile.id.clone(), "missing_model_path".to_string())
                .await;
            send_stream_event(&sender, "error", json!(response)).await;
            return;
        }

        if !Path::new(&profile.model_path).is_absolute() {
            let response = self
                .reject_for_profile(
                    profile.id.clone(),
                    format!("model_path_must_be_absolute: {}", profile.model_path),
                )
                .await;
            send_stream_event(&sender, "error", json!(response)).await;
            return;
        }

        if !Path::new(&profile.model_path).is_file() {
            let response = self
                .reject_for_profile(
                    profile.id.clone(),
                    format!("model_path_not_found: {}", profile.model_path),
                )
                .await;
            send_stream_event(&sender, "error", json!(response)).await;
            return;
        }

        if let Err(message) = validate_llama_server_bin() {
            let response = self.reject_for_profile(profile.id.clone(), message).await;
            send_stream_event(&sender, "error", json!(response)).await;
            return;
        }

        let system_prompt = resolve_system_prompt(&config, payload.system_prompt);
        let system_prompt_chars = system_prompt
            .as_deref()
            .map(|value| value.chars().count())
            .unwrap_or_default();
        let system_prompt_preview = system_prompt
            .as_deref()
            .map(|value| preview_text(value, 160))
            .filter(|value| !value.is_empty());
        let system_prompt_applied = system_prompt_chars > 0;

        self.update_state(|state| {
            state.stage = RuntimeStage::Starting;
            state.model_loaded = false;
            state.active_model_profile_id = Some(profile.id.clone());
            state.total_requests = state.total_requests.saturating_add(1);
            state.last_event = Some("starting_llama_server_stream".to_string());
            state.last_error = None;
            state.last_request_epoch_seconds = Some(now_epoch_seconds());
            state.last_system_prompt_chars = system_prompt_chars;
            state.last_system_prompt_preview = system_prompt_preview.clone();
            state.server_url = Some(self.server_url.clone());
        })
        .await;

        send_stream_event(
            &sender,
            "status",
            json!({
                "stage": "starting",
                "active_model_profile_id": profile.id.clone(),
                "server_url": self.server_url.clone(),
            }),
        )
        .await;

        let model_started = match self.ensure_llama_server_ready(&profile).await {
            Ok(started) => started,
            Err(message) => {
                let response = self
                    .fail(
                        profile.id.clone(),
                        message,
                        system_prompt_applied,
                        system_prompt_chars,
                        system_prompt_preview.clone(),
                    )
                    .await;
                send_stream_event(&sender, "error", json!(response)).await;
                return;
            }
        };

        self.update_state(|state| {
            state.stage = RuntimeStage::Generating;
            state.model_loaded = true;
            state.active_model_profile_id = Some(profile.id.clone());
            state.last_event = Some("stream_generating".to_string());
            state.last_error = None;
            state.server_url = Some(self.server_url.clone());
        })
        .await;

        send_stream_event(
            &sender,
            "status",
            json!({
                "stage": "generating",
                "active_model_profile_id": profile.id.clone(),
                "model_started": model_started,
                "system_prompt_applied": system_prompt_applied,
                "system_prompt_chars": system_prompt_chars,
                "system_prompt_preview": system_prompt_preview.clone(),
                "server_url": self.server_url.clone(),
            }),
        )
        .await;

        let generated = match self
            .send_chat_completion_stream(&profile, system_prompt.as_deref(), &prompt, &sender)
            .await
        {
            Ok(generated) => generated,
            Err(message) => {
                let response = self
                    .fail(
                        profile.id.clone(),
                        message,
                        system_prompt_applied,
                        system_prompt_chars,
                        system_prompt_preview.clone(),
                    )
                    .await;
                send_stream_event(&sender, "error", json!(response)).await;
                return;
            }
        };

        let mut stopped_after_response = false;
        if config.unload_after_response && !config.keep_model_loaded {
            stopped_after_response = true;
            let _ = self.stop_llama_server().await;
        }

        let snapshot = self
            .update_state(|state| {
                state.stage = RuntimeStage::Completed;
                state.model_loaded = !stopped_after_response;
                state.active_model_profile_id = Some(profile.id.clone());
                state.last_event = Some(if stopped_after_response {
                    "stream_completed_and_unloaded".to_string()
                } else {
                    "stream_completed_keep_loaded".to_string()
                });
                state.last_error = None;
                state.server_url = Some(self.server_url.clone());
            })
            .await;

        let response = RuntimeChatResponse {
            accepted: true,
            model_started,
            model_stopped_after_response: stopped_after_response,
            model_loaded: snapshot.model_loaded,
            stage: snapshot.stage,
            active_model_profile_id: snapshot.active_model_profile_id,
            generated_text: Some(generated.visible_text),
            reasoning_text: generated.reasoning_text,
            message: if stopped_after_response {
                "llama-server streaming response completed and runtime unloaded".to_string()
            } else {
                "llama-server streaming response completed and runtime kept loaded".to_string()
            },
            system_prompt_applied,
            system_prompt_chars,
            system_prompt_preview,
            server_url: Some(self.server_url.clone()),
        };
        send_stream_event(&sender, "done", json!(response)).await;
    }

    async fn send_chat_completion_stream(
        &self,
        profile: &ModelProfileConfig,
        system_prompt: Option<&str>,
        user_prompt: &str,
        sender: &mpsc::Sender<Result<Event, Infallible>>,
    ) -> Result<RuntimeGeneratedText, String> {
        let messages = build_chat_messages(profile, system_prompt, user_prompt);
        let body = build_chat_completion_body(profile, true, messages);

        let response = self
            .client
            .post(format!("{}/v1/chat/completions", self.server_url))
            .json(&body)
            .send()
            .await
            .map_err(|error| format!("stream_request_timeout_or_connection_error: {error}"))?;

        let status = response.status();
        if !status.is_success() {
            let text = response
                .text()
                .await
                .unwrap_or_else(|error| format!("failed_to_read_error_body: {error}"));
            return Err(format!(
                "llama_server_stream_http_{}: {text}",
                status.as_u16()
            ));
        }

        let mut visible_text = String::new();
        let mut reasoning_text = String::new();
        let mut thinking_capture = ThinkingTagCapture::default();
        let mut line_buffer = String::new();
        let mut stream = response.bytes_stream();

        while let Some(chunk) = stream.next().await {
            if self.stop_requested.load(Ordering::SeqCst) {
                return Err("generation_stopped_by_user".to_string());
            }

            let chunk = chunk.map_err(|error| format!("stream_read_error: {error}"))?;
            line_buffer.push_str(&String::from_utf8_lossy(&chunk));

            while let Some(newline_index) = line_buffer.find('\n') {
                let raw_line = line_buffer[..newline_index]
                    .trim_end_matches('\r')
                    .trim()
                    .to_string();
                line_buffer = line_buffer[newline_index + 1..].to_string();

                if raw_line.is_empty() || raw_line.starts_with(':') {
                    continue;
                }

                let Some(data) = raw_line.strip_prefix("data:") else {
                    continue;
                };
                let data = data.trim();
                if data == "[DONE]" {
                    let tail = thinking_capture.finish();
                    stream_capture_delta(
                        sender,
                        profile,
                        &self.server_url,
                        &mut visible_text,
                        &mut reasoning_text,
                        tail,
                    )
                    .await;

                    return Ok(RuntimeGeneratedText {
                        visible_text: visible_text.trim().to_string(),
                        reasoning_text: clean_optional_text(&reasoning_text),
                    });
                }

                let value: Value = match serde_json::from_str(data) {
                    Ok(value) => value,
                    Err(_) => continue,
                };

                if let Some(reasoning_delta) = extract_stream_reasoning_delta(&value) {
                    if !reasoning_delta.is_empty() {
                        stream_reasoning_delta(
                            sender,
                            profile,
                            &self.server_url,
                            &mut reasoning_text,
                            reasoning_delta,
                        )
                        .await;
                    }
                }

                if let Some(delta) = extract_stream_delta(&value) {
                    if delta.is_empty() {
                        continue;
                    }

                    let captured = thinking_capture.push(&delta);
                    stream_capture_delta(
                        sender,
                        profile,
                        &self.server_url,
                        &mut visible_text,
                        &mut reasoning_text,
                        captured,
                    )
                    .await;
                }
            }
        }

        let tail = thinking_capture.finish();
        stream_capture_delta(
            sender,
            profile,
            &self.server_url,
            &mut visible_text,
            &mut reasoning_text,
            tail,
        )
        .await;

        Ok(RuntimeGeneratedText {
            visible_text: visible_text.trim().to_string(),
            reasoning_text: clean_optional_text(&reasoning_text),
        })
    }

    async fn stop_llama_server(&self) -> Result<(), String> {
        let mut child_guard = self.llama_server_child.lock().await;
        if let Some(mut child) = child_guard.take() {
            child
                .start_kill()
                .map_err(|error| format!("llama_server_kill_failed: {error}"))?;
            let _ = child.wait().await;
        }
        Ok(())
    }

    async fn reject(&self, message: String) -> RuntimeChatResponse {
        let snapshot = self
            .update_state(|state| {
                state.stage = RuntimeStage::Error;
                state.model_loaded = false;
                state.last_event = Some("runtime_request_rejected".to_string());
                state.last_error = Some(message.clone());
                state.last_request_epoch_seconds = Some(now_epoch_seconds());
                state.last_system_prompt_chars = 0;
                state.last_system_prompt_preview = None;
            })
            .await;

        RuntimeChatResponse {
            accepted: false,
            model_started: false,
            model_stopped_after_response: false,
            model_loaded: snapshot.model_loaded,
            stage: snapshot.stage,
            active_model_profile_id: snapshot.active_model_profile_id,
            generated_text: None,
            reasoning_text: None,
            message,
            system_prompt_applied: false,
            system_prompt_chars: snapshot.last_system_prompt_chars,
            system_prompt_preview: snapshot.last_system_prompt_preview,
            server_url: Some(self.server_url.clone()),
        }
    }

    async fn reject_for_profile(&self, profile_id: String, message: String) -> RuntimeChatResponse {
        let snapshot = self
            .update_state(|state| {
                state.stage = RuntimeStage::Error;
                state.model_loaded = false;
                state.active_model_profile_id = Some(profile_id);
                state.last_event = Some("runtime_request_rejected".to_string());
                state.last_error = Some(message.clone());
                state.last_request_epoch_seconds = Some(now_epoch_seconds());
                state.last_system_prompt_chars = 0;
                state.last_system_prompt_preview = None;
                state.server_url = Some(self.server_url.clone());
            })
            .await;

        RuntimeChatResponse {
            accepted: false,
            model_started: false,
            model_stopped_after_response: false,
            model_loaded: snapshot.model_loaded,
            stage: snapshot.stage,
            active_model_profile_id: snapshot.active_model_profile_id,
            generated_text: None,
            reasoning_text: None,
            message,
            system_prompt_applied: false,
            system_prompt_chars: snapshot.last_system_prompt_chars,
            system_prompt_preview: snapshot.last_system_prompt_preview,
            server_url: Some(self.server_url.clone()),
        }
    }

    async fn fail(
        &self,
        profile_id: String,
        message: String,
        system_prompt_applied: bool,
        system_prompt_chars: usize,
        system_prompt_preview: Option<String>,
    ) -> RuntimeChatResponse {
        let _ = self.stop_llama_server().await;
        let snapshot = self
            .update_state(|state| {
                state.stage = RuntimeStage::Error;
                state.model_loaded = false;
                state.active_model_profile_id = Some(profile_id);
                state.last_event = Some("runtime_error".to_string());
                state.last_error = Some(message.clone());
                state.server_url = Some(self.server_url.clone());
            })
            .await;

        RuntimeChatResponse {
            accepted: false,
            model_started: false,
            model_stopped_after_response: true,
            model_loaded: snapshot.model_loaded,
            stage: snapshot.stage,
            active_model_profile_id: snapshot.active_model_profile_id,
            generated_text: None,
            reasoning_text: None,
            message,
            system_prompt_applied,
            system_prompt_chars,
            system_prompt_preview,
            server_url: Some(self.server_url.clone()),
        }
    }

    async fn update_state<F>(&self, update: F) -> RuntimeSnapshot
    where
        F: FnOnce(&mut RuntimeSnapshot),
    {
        let mut state = self.state.write().await;
        update(&mut state);
        state.clone()
    }
}

fn resolve_system_prompt(config: &EngineConfig, override_prompt: Option<String>) -> Option<String> {
    override_prompt
        .as_deref()
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .map(ToOwned::to_owned)
        .or_else(|| {
            let value = config.system_prompt.trim();
            if value.is_empty() {
                None
            } else {
                Some(value.to_string())
            }
        })
}

fn spawn_llama_server(profile: &ModelProfileConfig) -> std::io::Result<Child> {
    let server_bin = resolve_llama_server_bin();

    Command::new(server_bin)
        .arg("-m")
        .arg(&profile.model_path)
        .arg("--host")
        .arg(DEFAULT_LLAMA_SERVER_HOST)
        .arg("--port")
        .arg(runtime_server_port().to_string())
        .arg("-c")
        .arg(profile.context_size.to_string())
        .arg("-t")
        .arg(profile.threads.to_string())
        .arg("-b")
        .arg(profile.batch_size.to_string())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
}

fn resolve_llama_server_bin() -> String {
    env::var("LOGIXA_LLAMA_SERVER_BIN")
        .ok()
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
        .unwrap_or_else(|| DEFAULT_LLAMA_SERVER_BIN.to_string())
}

fn validate_llama_server_bin() -> Result<(), String> {
    let server_bin = resolve_llama_server_bin();
    let server_path = Path::new(&server_bin);

    if server_path.components().count() > 1 {
        if server_path.is_file() {
            return Ok(());
        }

        return Err(format!("{LLAMA_SERVER_MAINTENANCE_MESSAGE}: {server_bin}"));
    }

    let Some(path_list) = env::var_os("PATH") else {
        return Err(format!("{LLAMA_SERVER_MAINTENANCE_MESSAGE}: PATH is empty"));
    };

    for directory in env::split_paths(&path_list) {
        if directory.join(&server_bin).is_file() {
            return Ok(());
        }
    }

    Err(format!("{LLAMA_SERVER_MAINTENANCE_MESSAGE}: {server_bin}"))
}
fn runtime_server_url() -> String {
    env::var("LOGIXA_LLAMA_SERVER_URL")
        .ok()
        .map(|value| value.trim().trim_end_matches('/').to_string())
        .filter(|value| !value.is_empty())
        .unwrap_or_else(|| {
            format!(
                "http://{}:{}",
                DEFAULT_LLAMA_SERVER_HOST,
                runtime_server_port()
            )
        })
}

fn runtime_server_port() -> u16 {
    env::var("LOGIXA_LLAMA_SERVER_PORT")
        .ok()
        .and_then(|value| value.parse::<u16>().ok())
        .unwrap_or(DEFAULT_LLAMA_SERVER_PORT)
}

fn build_chat_messages(
    profile: &ModelProfileConfig,
    system_prompt: Option<&str>,
    user_prompt: &str,
) -> Vec<Value> {
    let mut messages = Vec::new();
    let thinking_switch = qwen_thinking_switch(profile);

    match (system_prompt.map(str::trim).filter(|value| !value.is_empty()), thinking_switch) {
        (Some(system_prompt), Some(switch)) => {
            messages.push(json!({
                "role": "system",
                "content": format!("{system_prompt}\n\n{switch}")
            }));
        }
        (Some(system_prompt), None) => {
            messages.push(json!({"role": "system", "content": system_prompt}));
        }
        (None, Some(switch)) => {
            messages.push(json!({"role": "system", "content": switch}));
        }
        (None, None) => {}
    }

    messages.push(json!({"role": "user", "content": user_prompt}));
    messages
}

fn build_chat_completion_body(
    profile: &ModelProfileConfig,
    stream: bool,
    messages: Vec<Value>,
) -> Value {
    let mut body = json!({
        "model": profile.id.clone(),
        "stream": stream,
        "max_tokens": profile.max_tokens,
        "temperature": profile.temperature,
        "top_p": profile.top_p,
        "top_k": profile.top_k,
        "min_p": profile.min_p,
        "repeat_penalty": profile.repeat_penalty,
        "presence_penalty": profile.presence_penalty,
        "messages": messages
    });

    if is_qwen_profile(profile) {
        if let Some(object) = body.as_object_mut() {
            object.insert(
                "chat_template_kwargs".to_string(),
                json!({"enable_thinking": profile.enable_thinking}),
            );
        }
    }

    body
}

fn qwen_thinking_switch(profile: &ModelProfileConfig) -> Option<&'static str> {
    if !is_qwen_profile(profile) {
        return None;
    }

    Some(if profile.enable_thinking {
        "/think"
    } else {
        "/no_think"
    })
}

fn is_qwen_profile(profile: &ModelProfileConfig) -> bool {
    let marker = format!(
        "{} {} {}",
        profile.id.to_lowercase(),
        profile.name.to_lowercase(),
        profile.model_path.to_lowercase()
    );
    marker.contains("qwen")
}

#[derive(Debug, Clone, Default)]
struct ThinkingCaptureDelta {
    visible: String,
    reasoning: String,
}

#[derive(Default)]
struct ThinkingTagCapture {
    pending: String,
    inside_think: bool,
}

impl ThinkingTagCapture {
    fn push(&mut self, delta: &str) -> ThinkingCaptureDelta {
        self.pending.push_str(delta);
        let mut captured = ThinkingCaptureDelta::default();

        loop {
            if self.inside_think {
                if let Some(end_index) = self.pending.find("</think>") {
                    captured.reasoning.push_str(&self.pending[..end_index]);
                    self.pending.drain(..end_index + "</think>".len());
                    self.inside_think = false;
                    continue;
                }

                let keep = partial_end_tag_suffix_len(&self.pending);
                let split_at = self.pending.len().saturating_sub(keep);
                captured.reasoning.push_str(&self.pending[..split_at]);
                self.pending = self.pending[split_at..].to_string();
                break;
            }

            if let Some(start_index) = self.pending.find("<think>") {
                captured.visible.push_str(&self.pending[..start_index]);
                self.pending.drain(..start_index + "<think>".len());
                self.inside_think = true;
                continue;
            }

            let keep = partial_start_tag_suffix_len(&self.pending);
            let split_at = self.pending.len().saturating_sub(keep);
            captured.visible.push_str(&self.pending[..split_at]);
            self.pending = self.pending[split_at..].to_string();
            break;
        }

        captured
    }

    fn finish(&mut self) -> ThinkingCaptureDelta {
        let mut captured = ThinkingCaptureDelta::default();

        if self.inside_think {
            if let Some(end_index) = self.pending.find("</think>") {
                captured.reasoning.push_str(&self.pending[..end_index]);
                let after_end = end_index + "</think>".len();
                captured.visible.push_str(&strip_think_blocks(&self.pending[after_end..]));
            } else {
                captured.reasoning.push_str(&self.pending);
            }
        } else {
            captured.visible.push_str(&strip_think_blocks(&self.pending));
        }

        self.pending.clear();
        self.inside_think = false;
        captured
    }
}

fn strip_think_blocks(value: &str) -> String {
    let mut remaining = value.to_string();
    let mut output = String::new();

    loop {
        let Some(start_index) = remaining.find("<think>") else {
            output.push_str(&remaining);
            break;
        };

        output.push_str(&remaining[..start_index]);
        let after_start = start_index + "<think>".len();
        let after = remaining[after_start..].to_string();

        if let Some(end_index) = after.find("</think>") {
            remaining = after[end_index + "</think>".len()..].to_string();
        } else {
            break;
        }
    }

    output
}

fn partial_start_tag_suffix_len(value: &str) -> usize {
    let tag = "<think>";

    for len in (1..tag.len()).rev() {
        if value.ends_with(&tag[..len]) {
            return len;
        }
    }

    0
}

fn partial_end_tag_suffix_len(value: &str) -> usize {
    let tag = "</think>";

    for len in (1..tag.len()).rev() {
        if value.ends_with(&tag[..len]) {
            return len;
        }
    }

    0
}

async fn stream_capture_delta(
    sender: &mpsc::Sender<Result<Event, Infallible>>,
    profile: &ModelProfileConfig,
    server_url: &str,
    visible_text: &mut String,
    reasoning_text: &mut String,
    captured: ThinkingCaptureDelta,
) {
    if !captured.reasoning.is_empty() {
        stream_reasoning_delta(
            sender,
            profile,
            server_url,
            reasoning_text,
            captured.reasoning,
        )
        .await;
    }

    if captured.visible.is_empty() {
        return;
    }

    visible_text.push_str(&captured.visible);
    send_stream_event(
        sender,
        "token",
        json!({
            "delta": captured.visible,
            "stage": "generating",
            "active_model_profile_id": profile.id.clone(),
            "server_url": server_url,
        }),
    )
    .await;
}

async fn stream_reasoning_delta(
    sender: &mpsc::Sender<Result<Event, Infallible>>,
    profile: &ModelProfileConfig,
    server_url: &str,
    reasoning_text: &mut String,
    reasoning_delta: String,
) {
    reasoning_text.push_str(&reasoning_delta);
    send_stream_event(
        sender,
        "reasoning_token",
        json!({
            "reasoning_delta": reasoning_delta,
            "stage": "thinking",
            "active_model_profile_id": profile.id.clone(),
            "server_url": server_url,
        }),
    )
    .await;
}

fn clean_optional_text(value: &str) -> Option<String> {
    let clean = value.trim();
    if clean.is_empty() {
        None
    } else {
        Some(clean.to_string())
    }
}

async fn send_stream_event(
    sender: &mpsc::Sender<Result<Event, Infallible>>,
    event_name: &str,
    payload: Value,
) {
    let _ = sender
        .send(Ok(Event::default()
            .event(event_name)
            .data(payload.to_string())))
        .await;
}

fn extract_stream_delta(value: &Value) -> Option<String> {
    value
        .pointer("/choices/0/delta/content")
        .and_then(Value::as_str)
        .or_else(|| value.pointer("/choices/0/text").and_then(Value::as_str))
        .or_else(|| value.pointer("/delta").and_then(Value::as_str))
        .map(ToOwned::to_owned)
}

fn extract_stream_reasoning_delta(value: &Value) -> Option<String> {
    value
        .pointer("/choices/0/delta/reasoning_content")
        .and_then(Value::as_str)
        .or_else(|| {
            value
                .pointer("/choices/0/delta/reasoning")
                .and_then(Value::as_str)
        })
        .or_else(|| {
            value
                .pointer("/choices/0/message/reasoning_content")
                .and_then(Value::as_str)
        })
        .or_else(|| value.pointer("/reasoning_delta").and_then(Value::as_str))
        .or_else(|| value.pointer("/reasoning_content").and_then(Value::as_str))
        .map(ToOwned::to_owned)
}

fn extract_generated_text(value: &Value) -> Option<String> {
    value
        .pointer("/choices/0/message/content")
        .and_then(Value::as_str)
        .or_else(|| value.pointer("/choices/0/text").and_then(Value::as_str))
        .map(strip_think_blocks)
        .map(|text| text.trim().to_string())
        .filter(|text| !text.is_empty())
}

fn preview_text(value: &str, max_chars: usize) -> String {
    let normalized = value.split_whitespace().collect::<Vec<_>>().join(" ");
    normalized.chars().take(max_chars).collect()
}

fn now_epoch_seconds() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_secs())
        .unwrap_or_default()
}
