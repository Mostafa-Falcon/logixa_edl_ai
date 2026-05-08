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
    pub repeat_penalty: f32,
    pub presence_penalty: f32,
    pub prompt_template: String,
    pub model_role: String,
    pub load_policy: String,
    pub ram_policy: String,
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
            repeat_penalty: 1.10,
            presence_penalty: 0.10,
            prompt_template: default_prompt_template(),
            model_role: "fast".to_string(),
            load_policy: "on_demand".to_string(),
            ram_policy: "conservative".to_string(),
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

        if !self.repeat_penalty.is_finite() || self.repeat_penalty < 0.0 {
            self.repeat_penalty = 1.10;
        }

        if !self.presence_penalty.is_finite() || self.presence_penalty < 0.0 {
            self.presence_penalty = 0.10;
        }

        self.prompt_template = normalize_text(self.prompt_template, &default_prompt_template());
        self.model_role = normalize_text(self.model_role, "fast");
        self.load_policy = normalize_text(self.load_policy, "on_demand");
        self.ram_policy = normalize_text(self.ram_policy, "conservative");

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

fn default_prompt_template() -> String {
    "<start_of_turn>user
{system_prompt}

{user_prompt}<end_of_turn>
<start_of_turn>model"
        .to_string()
}
