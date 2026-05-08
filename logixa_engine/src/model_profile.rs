use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct ModelProfileConfig {
    pub id: String,
    pub name: String,
    pub model_path: String,
    pub context_size: u32,
    pub threads: u16,
    pub batch_size: u32,
    pub max_tokens: u32,
    pub temperature: f32,
    pub top_p: f32,
    pub top_k: u32,
}

impl Default for ModelProfileConfig {
    fn default() -> Self {
        Self {
            id: "default_local_model".to_string(),
            name: "Default Local Model".to_string(),
            model_path: String::new(),
            context_size: 2048,
            threads: 6,
            batch_size: 256,
            max_tokens: 512,
            temperature: 1.0,
            top_p: 0.95,
            top_k: 64,
        }
    }
}

impl ModelProfileConfig {
    pub fn normalized(mut self) -> Self {
        self.id = normalize_text(self.id, "default_local_model");
        self.name = normalize_text(self.name, "Default Local Model");
        self.model_path = self.model_path.trim().to_string();

        if self.context_size == 0 {
            self.context_size = 2048;
        }

        if self.threads == 0 {
            self.threads = 1;
        }

        if self.batch_size == 0 {
            self.batch_size = 256;
        }

        if self.max_tokens == 0 {
            self.max_tokens = 512;
        }

        if !self.temperature.is_finite() || self.temperature <= 0.0 {
            self.temperature = 1.0;
        }

        if !self.top_p.is_finite() || self.top_p <= 0.0 || self.top_p > 1.0 {
            self.top_p = 0.95;
        }

        if self.top_k == 0 {
            self.top_k = 64;
        }

        self
    }

    pub fn has_model_path(&self) -> bool {
        !self.model_path.trim().is_empty()
    }
}

fn normalize_text(value: String, fallback: &str) -> String {
    let normalized = value.trim().to_string();
    if normalized.is_empty() {
        fallback.to_string()
    } else {
        normalized
    }
}
