use crate::model_profile::ModelProfileConfig;
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::{fs, path::Path};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct EngineConfig {
    pub host: String,
    pub port: u16,
    pub local_model_enabled: bool,
    pub active_model_profile_id: Option<String>,
    pub active_model_profile: Option<ModelProfileConfig>,
    pub system_prompt: String,
    pub auto_start_on_message: bool,
    pub keep_model_loaded: bool,
    pub unload_after_response: bool,
    pub allow_background_model: bool,
}

impl Default for EngineConfig {
    fn default() -> Self {
        Self {
            host: "127.0.0.1".to_string(),
            port: 8787,
            local_model_enabled: false,
            active_model_profile_id: None,
            active_model_profile: None,
            system_prompt: default_system_prompt(),
            auto_start_on_message: true,
            keep_model_loaded: false,
            unload_after_response: true,
            allow_background_model: false,
        }
    }
}

impl EngineConfig {
    pub fn load_or_create(config_path: &Path) -> Result<Self> {
        if config_path.exists() {
            let raw = fs::read_to_string(config_path).with_context(|| {
                format!("failed to read config file: {}", config_path.display())
            })?;

            let config: Self = serde_json::from_str(&raw).with_context(|| {
                format!("failed to parse config file: {}", config_path.display())
            })?;

            return Ok(config.normalized());
        }

        let config = Self::default();
        config.save_to(config_path)?;
        Ok(config)
    }

    pub fn save_to(&self, config_path: &Path) -> Result<()> {
        if let Some(parent) = config_path.parent() {
            fs::create_dir_all(parent).with_context(|| {
                format!("failed to create config directory: {}", parent.display())
            })?;
        }

        let pretty =
            serde_json::to_string_pretty(self).context("failed to serialize engine config")?;

        fs::write(config_path, format!("{pretty}\n"))
            .with_context(|| format!("failed to write config file: {}", config_path.display()))?;

        Ok(())
    }

    fn normalized(mut self) -> Self {
        if self.host.trim().is_empty() {
            self.host = "127.0.0.1".to_string();
        }

        if self.port == 0 {
            self.port = 8787;
        }

        self.system_prompt = normalize_system_prompt(self.system_prompt);

        if let Some(profile) = self.active_model_profile.take() {
            let profile = profile.normalized();
            self.active_model_profile_id = Some(profile.id.clone());
            self.active_model_profile = Some(profile);
        }

        self
    }
}

pub fn default_system_prompt() -> String {
    "أنت Logixa EDL AI، مساعد محلي داخل بيئة تطوير وتحكم ذكية.

التزم بالآتي:
- ساعد المستخدم بوضوح وبأسلوب عربي مصري بسيط عند الحاجة.
- لا تغيّر الملفات أو تشغّل أدوات إلا بناءً على طلب واضح.
- احترم سياسة تشغيل الموديل المحلي: لا يعمل إلا عند إرسال رسالة، ولا يبقى محمّلًا إلا لو المستخدم فعّل ذلك.
- عند تنفيذ مهام تقنية، التزم بالخطوات والملفات المحددة."
        .to_string()
}

pub fn normalize_system_prompt(value: String) -> String {
    let normalized = value.trim().to_string();
    if normalized.is_empty() {
        default_system_prompt()
    } else {
        normalized
    }
}
