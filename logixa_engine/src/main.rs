mod config;
mod memory;
mod model_profile;
mod routes;
mod runtime;
mod state;

use anyhow::{Context, Result};
use config::EngineConfig;
use memory::MemoryStore;
use routes::router;
use state::EngineState;
use std::{env, net::SocketAddr, path::PathBuf};
use tower_http::{cors::CorsLayer, trace::TraceLayer};
use tracing::info;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() -> Result<()> {
    init_tracing();

    let config_path = resolve_config_path();
    let config = EngineConfig::load_or_create(&config_path)?;
    let memory_path = resolve_memory_path();
    let memory = MemoryStore::new(memory_path.clone())?;
    let address: SocketAddr = format!("{}:{}", config.host, config.port)
        .parse()
        .context("failed to parse engine host/port")?;

    let state = EngineState::new(config, config_path.clone(), memory);

    let app = router(state)
        .layer(CorsLayer::permissive())
        .layer(TraceLayer::new_for_http());

    let listener = tokio::net::TcpListener::bind(address)
        .await
        .with_context(|| format!("failed to bind Logixa Engine on {address}"))?;

    info!(
        service = "logixa_engine",
        %address,
        config_path = %config_path.display(),
        memory_path = %memory_path.display(),
        "Logixa Engine started"
    );

    axum::serve(listener, app)
        .await
        .context("Logixa Engine server stopped unexpectedly")?;

    Ok(())
}

fn resolve_config_path() -> PathBuf {
    env::var_os("LOGIXA_ENGINE_CONFIG")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("logixa_engine_config.json"))
}

fn resolve_memory_path() -> PathBuf {
    env::var_os("LOGIXA_ENGINE_MEMORY_DB")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("logixa_engine_memory.sqlite"))
}

fn init_tracing() {
    let env_filter = tracing_subscriber::EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| "logixa_engine=info,tower_http=info".into());

    tracing_subscriber::registry()
        .with(env_filter)
        .with(tracing_subscriber::fmt::layer())
        .init();
}
