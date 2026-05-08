use crate::{
    config::{normalize_system_prompt, EngineConfig},
    memory::{
        CreateConversationRequest, CreateMemoryItemRequest, CreateMessageRequest,
        CreateWorkspaceSessionRequest, UpsertExpertRequest,
    },
    model_profile::ModelProfileConfig,
    runtime::{RuntimeChatRequest, RuntimeChatResponse, RuntimeSnapshot},
    state::EngineState,
};
use axum::{
    extract::{Query, State},
    response::{
        sse::{KeepAlive, Sse},
        IntoResponse,
    },
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

const SERVICE_NAME: &str = "logixa_engine";

#[derive(Debug, Serialize)]
struct HealthResponse {
    ok: bool,
    service: &'static str,
    version: &'static str,
    config_path: String,
}

#[derive(Debug, Serialize)]
struct StatusResponse {
    engine_running: bool,
    local_model_enabled: bool,
    model_loaded: bool,
    active_model_profile_id: Option<String>,
    auto_start_on_message: bool,
    keep_model_loaded: bool,
    unload_after_response: bool,
    allow_background_model: bool,
    uptime_seconds: u64,
    config_path: String,
    memory_db_path: String,
    runtime: RuntimeSnapshot,
}

#[derive(Debug, Deserialize)]
struct RuntimeSystemPromptRequest {
    system_prompt: String,
}

#[derive(Debug, Serialize)]
struct RuntimeSystemPromptResponse {
    saved: bool,
    system_prompt_chars: usize,
    system_prompt_preview: String,
    message: String,
}

#[derive(Debug, Deserialize)]
struct RuntimeProfileRequest {
    model_profile: ModelProfileConfig,
    #[serde(default)]
    local_model_enabled: Option<bool>,
    #[serde(default)]
    auto_start_on_message: Option<bool>,
    #[serde(default)]
    keep_model_loaded: Option<bool>,
    #[serde(default)]
    unload_after_response: Option<bool>,
    #[serde(default)]
    allow_background_model: Option<bool>,
}

#[derive(Debug, Serialize)]
struct RuntimeProfileResponse {
    saved: bool,
    active_model_profile_id: String,
    model_profile: ModelProfileConfig,
    local_model_enabled: bool,
    auto_start_on_message: bool,
    keep_model_loaded: bool,
    unload_after_response: bool,
    allow_background_model: bool,
    message: String,
}

#[derive(Debug, Serialize)]
struct RuntimeUnloadResponse {
    unloaded: bool,
    runtime: RuntimeSnapshot,
}

#[derive(Debug, Deserialize)]
struct MessagesQuery {
    conversation_id: String,
}

pub fn router(state: EngineState) -> Router {
    Router::new()
        .route("/health", get(health))
        .route("/status", get(status))
        .route("/settings", get(settings))
        .route("/runtime/status", get(runtime_status))
        .route("/runtime/system-prompt", post(set_runtime_system_prompt))
        .route("/runtime/profile", post(set_runtime_profile))
        .route("/runtime/chat", post(runtime_chat))
        .route("/runtime/chat/stream", post(runtime_chat_stream))
        .route("/runtime/stop-generation", post(runtime_stop_generation))
        .route("/runtime/unload", post(runtime_unload))
        .route("/memory/status", get(memory_status))
        .route(
            "/memory/conversations",
            get(list_memory_conversations).post(create_memory_conversation),
        )
        .route(
            "/memory/messages",
            get(list_memory_messages).post(create_memory_message),
        )
        .route(
            "/memory/items",
            get(list_memory_items).post(create_memory_item),
        )
        .route(
            "/memory/experts",
            get(list_memory_experts).post(upsert_memory_expert),
        )
        .route(
            "/memory/workspace-sessions",
            get(list_memory_workspace_sessions).post(create_memory_workspace_session),
        )
        .route(
            "/memory/selected-model-profile",
            get(memory_selected_model_profile),
        )
        .with_state(state)
}

async fn health(State(state): State<EngineState>) -> impl IntoResponse {
    Json(HealthResponse {
        ok: true,
        service: SERVICE_NAME,
        version: env!("CARGO_PKG_VERSION"),
        config_path: state.config_path.display().to_string(),
    })
}

async fn status(State(state): State<EngineState>) -> impl IntoResponse {
    let config = state.config.read().await.clone();
    let runtime = state.runtime.snapshot().await;

    Json(StatusResponse {
        engine_running: true,
        local_model_enabled: config.local_model_enabled,
        model_loaded: runtime.model_loaded,
        active_model_profile_id: config.active_model_profile_id,
        auto_start_on_message: config.auto_start_on_message,
        keep_model_loaded: config.keep_model_loaded,
        unload_after_response: config.unload_after_response,
        allow_background_model: config.allow_background_model,
        uptime_seconds: state.uptime_seconds(),
        config_path: state.config_path.display().to_string(),
        memory_db_path: state.memory.db_path_display(),
        runtime,
    })
}

async fn settings(State(state): State<EngineState>) -> impl IntoResponse {
    let config: EngineConfig = state.config.read().await.clone();
    Json(config)
}

async fn runtime_status(State(state): State<EngineState>) -> impl IntoResponse {
    Json(state.runtime.snapshot().await)
}

async fn set_runtime_system_prompt(
    State(state): State<EngineState>,
    Json(payload): Json<RuntimeSystemPromptRequest>,
) -> impl IntoResponse {
    let system_prompt = normalize_system_prompt(payload.system_prompt);
    let system_prompt_chars = system_prompt.chars().count();
    let system_prompt_preview = preview_text(&system_prompt, 120);

    let save_result = {
        let mut config = state.config.write().await;
        config.system_prompt = system_prompt;
        config.save_to(state.config_path.as_ref().as_path())
    };

    Json(RuntimeSystemPromptResponse {
        saved: save_result.is_ok(),
        system_prompt_chars,
        system_prompt_preview,
        message: match save_result {
            Ok(()) => "runtime system prompt saved".to_string(),
            Err(error) => {
                format!("runtime system prompt updated in memory but failed to save: {error}")
            }
        },
    })
}

async fn set_runtime_profile(
    State(state): State<EngineState>,
    Json(payload): Json<RuntimeProfileRequest>,
) -> impl IntoResponse {
    let profile = payload.model_profile.normalized();

    let response = {
        let mut config = state.config.write().await;
        config.active_model_profile_id = Some(profile.id.clone());
        config.active_model_profile = Some(profile.clone());

        if let Some(value) = payload.local_model_enabled {
            config.local_model_enabled = value;
        }
        if let Some(value) = payload.auto_start_on_message {
            config.auto_start_on_message = value;
        }
        if let Some(value) = payload.keep_model_loaded {
            config.keep_model_loaded = value;
        }
        if let Some(value) = payload.unload_after_response {
            config.unload_after_response = value;
        }
        if let Some(value) = payload.allow_background_model {
            config.allow_background_model = value;
        }

        let save_result = config.save_to(state.config_path.as_ref().as_path());
        let profile_value = serde_json::to_value(&profile).unwrap_or(Value::Null);
        let memory_result = state
            .memory
            .save_selected_model_profile(&profile.id, &profile_value);

        RuntimeProfileResponse {
            saved: save_result.is_ok(),
            active_model_profile_id: profile.id.clone(),
            model_profile: profile,
            local_model_enabled: config.local_model_enabled,
            auto_start_on_message: config.auto_start_on_message,
            keep_model_loaded: config.keep_model_loaded,
            unload_after_response: config.unload_after_response,
            allow_background_model: config.allow_background_model,
            message: match (save_result, memory_result) {
                (Ok(()), Ok(())) => "runtime model profile saved".to_string(),
                (Err(error), _) => format!(
                    "runtime model profile updated in memory but failed to save config: {error}"
                ),
                (_, Err(error)) => format!(
                    "runtime model profile saved but failed to update memory snapshot: {error}"
                ),
            },
        }
    };

    Json(response)
}

async fn runtime_chat(
    State(state): State<EngineState>,
    Json(payload): Json<RuntimeChatRequest>,
) -> impl IntoResponse {
    let config = state.config.read().await.clone();
    let response: RuntimeChatResponse = state.runtime.prepare_chat(&config, payload).await;
    Json(response)
}

async fn runtime_chat_stream(
    State(state): State<EngineState>,
    Json(payload): Json<RuntimeChatRequest>,
) -> Sse<crate::runtime::RuntimeSseStream> {
    let config = state.config.read().await.clone();
    let stream = state.runtime.prepare_chat_stream(config, payload).await;
    Sse::new(stream).keep_alive(KeepAlive::default())
}

async fn runtime_stop_generation(State(state): State<EngineState>) -> impl IntoResponse {
    let runtime = state.runtime.stop_generation().await;
    Json(RuntimeUnloadResponse {
        unloaded: true,
        runtime,
    })
}

async fn runtime_unload(State(state): State<EngineState>) -> impl IntoResponse {
    let runtime = state.runtime.unload().await;
    Json(RuntimeUnloadResponse {
        unloaded: true,
        runtime,
    })
}

async fn memory_status(State(state): State<EngineState>) -> impl IntoResponse {
    json_result(state.memory.status())
}

async fn create_memory_conversation(
    State(state): State<EngineState>,
    Json(payload): Json<CreateConversationRequest>,
) -> impl IntoResponse {
    json_result(state.memory.create_conversation(payload))
}

async fn list_memory_conversations(State(state): State<EngineState>) -> impl IntoResponse {
    json_result(state.memory.list_conversations())
}

async fn create_memory_message(
    State(state): State<EngineState>,
    Json(payload): Json<CreateMessageRequest>,
) -> impl IntoResponse {
    json_result(state.memory.create_message(payload))
}

async fn list_memory_messages(
    State(state): State<EngineState>,
    Query(query): Query<MessagesQuery>,
) -> impl IntoResponse {
    json_result(state.memory.list_messages(query.conversation_id))
}

async fn create_memory_item(
    State(state): State<EngineState>,
    Json(payload): Json<CreateMemoryItemRequest>,
) -> impl IntoResponse {
    json_result(state.memory.create_memory_item(payload))
}

async fn list_memory_items(State(state): State<EngineState>) -> impl IntoResponse {
    json_result(state.memory.list_memory_items())
}

async fn upsert_memory_expert(
    State(state): State<EngineState>,
    Json(payload): Json<UpsertExpertRequest>,
) -> impl IntoResponse {
    json_result(state.memory.upsert_expert(payload))
}

async fn list_memory_experts(State(state): State<EngineState>) -> impl IntoResponse {
    json_result(state.memory.list_experts())
}

async fn create_memory_workspace_session(
    State(state): State<EngineState>,
    Json(payload): Json<CreateWorkspaceSessionRequest>,
) -> impl IntoResponse {
    json_result(state.memory.create_workspace_session(payload))
}

async fn list_memory_workspace_sessions(State(state): State<EngineState>) -> impl IntoResponse {
    json_result(state.memory.list_workspace_sessions())
}

async fn memory_selected_model_profile(State(state): State<EngineState>) -> impl IntoResponse {
    json_result(state.memory.selected_model_profile())
}

fn json_result<T>(result: anyhow::Result<T>) -> Json<Value>
where
    T: Serialize,
{
    match result {
        Ok(data) => Json(json!({ "ok": true, "data": data })),
        Err(error) => Json(json!({ "ok": false, "error": error.to_string() })),
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
