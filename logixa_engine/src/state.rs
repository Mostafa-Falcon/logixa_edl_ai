use crate::{config::EngineConfig, memory::MemoryStore, runtime::RuntimeManager};
use std::{path::PathBuf, sync::Arc, time::Instant};
use tokio::sync::RwLock;

#[derive(Clone)]
pub struct EngineState {
    pub config: Arc<RwLock<EngineConfig>>,
    pub config_path: Arc<PathBuf>,
    pub runtime: RuntimeManager,
    pub memory: MemoryStore,
    started_at: Instant,
}

impl EngineState {
    pub fn new(config: EngineConfig, config_path: PathBuf, memory: MemoryStore) -> Self {
        Self {
            config: Arc::new(RwLock::new(config)),
            config_path: Arc::new(config_path),
            runtime: RuntimeManager::default(),
            memory,
            started_at: Instant::now(),
        }
    }

    pub fn uptime_seconds(&self) -> u64 {
        self.started_at.elapsed().as_secs()
    }
}
