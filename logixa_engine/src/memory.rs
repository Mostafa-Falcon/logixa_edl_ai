use anyhow::{Context, Result};
use rusqlite::{params, Connection};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{fs, path::PathBuf, sync::Arc, time::{SystemTime, UNIX_EPOCH}};
use uuid::Uuid;

#[derive(Clone)]
pub struct MemoryStore {
    db_path: Arc<PathBuf>,
}

#[derive(Debug, Clone, Serialize)]
pub struct MemoryStatus {
    pub db_path: String,
    pub conversations: i64,
    pub messages: i64,
    pub memory_items: i64,
    pub experts: i64,
    pub workspace_sessions: i64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CreateConversationRequest {
    #[serde(default)]
    pub title: Option<String>,
    #[serde(default)]
    pub workspace_path: Option<String>,
    #[serde(default)]
    pub model_profile_id: Option<String>,
    #[serde(default)]
    pub system_prompt: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct ConversationRecord {
    pub id: String,
    pub title: String,
    pub workspace_path: Option<String>,
    pub model_profile_id: Option<String>,
    pub system_prompt_preview: Option<String>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CreateMessageRequest {
    pub conversation_id: String,
    pub role: String,
    pub content: String,
    #[serde(default)]
    pub model_profile_id: Option<String>,
    #[serde(default)]
    pub metadata: Option<Value>,
}

#[derive(Debug, Clone, Serialize)]
pub struct MessageRecord {
    pub id: String,
    pub conversation_id: String,
    pub role: String,
    pub content: String,
    pub model_profile_id: Option<String>,
    pub metadata: Option<Value>,
    pub created_at: i64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CreateMemoryItemRequest {
    pub key: String,
    pub value: String,
    #[serde(default)]
    pub source: Option<String>,
    #[serde(default)]
    pub tags: Vec<String>,
    #[serde(default)]
    pub metadata: Option<Value>,
}

#[derive(Debug, Clone, Serialize)]
pub struct MemoryItemRecord {
    pub id: String,
    pub key: String,
    pub value: String,
    pub source: Option<String>,
    pub tags: Vec<String>,
    pub metadata: Option<Value>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct UpsertExpertRequest {
    #[serde(default)]
    pub id: Option<String>,
    pub name: String,
    pub system_prompt: String,
    #[serde(default)]
    pub model_profile_id: Option<String>,
    #[serde(default)]
    pub metadata: Option<Value>,
}

#[derive(Debug, Clone, Serialize)]
pub struct ExpertRecord {
    pub id: String,
    pub name: String,
    pub system_prompt: String,
    pub model_profile_id: Option<String>,
    pub metadata: Option<Value>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CreateWorkspaceSessionRequest {
    pub workspace_path: String,
    #[serde(default)]
    pub workspace_name: Option<String>,
    #[serde(default)]
    pub active_file: Option<String>,
    #[serde(default)]
    pub metadata: Option<Value>,
}

#[derive(Debug, Clone, Serialize)]
pub struct WorkspaceSessionRecord {
    pub id: String,
    pub workspace_path: String,
    pub workspace_name: Option<String>,
    pub active_file: Option<String>,
    pub metadata: Option<Value>,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Clone, Serialize)]
pub struct SelectedModelProfileRecord {
    pub profile_id: Option<String>,
    pub profile: Option<Value>,
    pub updated_at: Option<i64>,
}

impl MemoryStore {
    pub fn new(db_path: PathBuf) -> Result<Self> {
        if let Some(parent) = db_path.parent() {
            if !parent.as_os_str().is_empty() {
                fs::create_dir_all(parent).with_context(|| {
                    format!("failed to create memory db directory: {}", parent.display())
                })?;
            }
        }

        let store = Self { db_path: Arc::new(db_path) };
        store.initialize()?;
        Ok(store)
    }

    pub fn db_path_display(&self) -> String {
        self.db_path.display().to_string()
    }

    pub fn initialize(&self) -> Result<()> {
        let conn = self.open()?;
        conn.execute_batch(
            "PRAGMA foreign_keys = ON;

            CREATE TABLE IF NOT EXISTS conversations (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                workspace_path TEXT,
                model_profile_id TEXT,
                system_prompt_preview TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS messages (
                id TEXT PRIMARY KEY,
                conversation_id TEXT NOT NULL,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                model_profile_id TEXT,
                metadata_json TEXT,
                created_at INTEGER NOT NULL,
                FOREIGN KEY(conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS memory_items (
                id TEXT PRIMARY KEY,
                key TEXT NOT NULL,
                value TEXT NOT NULL,
                source TEXT,
                tags_json TEXT NOT NULL,
                metadata_json TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS experts (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                system_prompt TEXT NOT NULL,
                model_profile_id TEXT,
                metadata_json TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS workspace_sessions (
                id TEXT PRIMARY KEY,
                workspace_path TEXT NOT NULL,
                workspace_name TEXT,
                active_file TEXT,
                metadata_json TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS selected_model_profile (
                id INTEGER PRIMARY KEY CHECK (id = 1),
                profile_id TEXT,
                profile_json TEXT,
                updated_at INTEGER NOT NULL
            );",
        )
        .context("failed to initialize memory schema")?;

        Ok(())
    }

    pub fn status(&self) -> Result<MemoryStatus> {
        let conn = self.open()?;
        Ok(MemoryStatus {
            db_path: self.db_path_display(),
            conversations: count_table(&conn, "conversations")?,
            messages: count_table(&conn, "messages")?,
            memory_items: count_table(&conn, "memory_items")?,
            experts: count_table(&conn, "experts")?,
            workspace_sessions: count_table(&conn, "workspace_sessions")?,
        })
    }

    pub fn create_conversation(&self, request: CreateConversationRequest) -> Result<ConversationRecord> {
        let conn = self.open()?;
        let now = now_epoch_seconds();
        let title = normalize_text(request.title.unwrap_or_default(), "محادثة جديدة");
        let system_prompt_preview = request.system_prompt.map(|value| preview_text(&value, 160));

        let record = ConversationRecord {
            id: new_id(),
            title,
            workspace_path: normalize_optional_text(request.workspace_path),
            model_profile_id: normalize_optional_text(request.model_profile_id),
            system_prompt_preview,
            created_at: now,
            updated_at: now,
        };

        conn.execute(
            "INSERT INTO conversations (id, title, workspace_path, model_profile_id, system_prompt_preview, created_at, updated_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            params![
                &record.id,
                &record.title,
                &record.workspace_path,
                &record.model_profile_id,
                &record.system_prompt_preview,
                record.created_at,
                record.updated_at,
            ],
        )
        .context("failed to insert conversation")?;

        Ok(record)
    }

    pub fn list_conversations(&self) -> Result<Vec<ConversationRecord>> {
        let conn = self.open()?;
        let mut stmt = conn.prepare(
            "SELECT id, title, workspace_path, model_profile_id, system_prompt_preview, created_at, updated_at
             FROM conversations
             ORDER BY updated_at DESC
             LIMIT 50",
        )?;

        let rows = stmt.query_map([], |row| {
            Ok(ConversationRecord {
                id: row.get(0)?,
                title: row.get(1)?,
                workspace_path: row.get(2)?,
                model_profile_id: row.get(3)?,
                system_prompt_preview: row.get(4)?,
                created_at: row.get(5)?,
                updated_at: row.get(6)?,
            })
        })?;

        collect_rows(rows)
    }

    pub fn create_message(&self, request: CreateMessageRequest) -> Result<MessageRecord> {
        let conn = self.open()?;
        let now = now_epoch_seconds();
        let metadata_json = to_json_string(request.metadata.as_ref())?;

        let record = MessageRecord {
            id: new_id(),
            conversation_id: normalize_text(request.conversation_id, "unknown_conversation"),
            role: normalize_text(request.role, "user"),
            content: request.content.trim().to_string(),
            model_profile_id: normalize_optional_text(request.model_profile_id),
            metadata: request.metadata,
            created_at: now,
        };

        conn.execute(
            "INSERT INTO messages (id, conversation_id, role, content, model_profile_id, metadata_json, created_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            params![
                &record.id,
                &record.conversation_id,
                &record.role,
                &record.content,
                &record.model_profile_id,
                metadata_json,
                record.created_at,
            ],
        )
        .context("failed to insert message")?;

        conn.execute(
            "UPDATE conversations SET updated_at = ?1 WHERE id = ?2",
            params![now, &record.conversation_id],
        )
        .context("failed to update conversation timestamp")?;

        Ok(record)
    }

    pub fn list_messages(&self, conversation_id: String) -> Result<Vec<MessageRecord>> {
        let conn = self.open()?;
        let mut stmt = conn.prepare(
            "SELECT id, conversation_id, role, content, model_profile_id, metadata_json, created_at
             FROM messages
             WHERE conversation_id = ?1
             ORDER BY created_at ASC
             LIMIT 200",
        )?;

        let rows = stmt.query_map(params![conversation_id], |row| {
            let metadata_json: Option<String> = row.get(5)?;
            Ok(MessageRecord {
                id: row.get(0)?,
                conversation_id: row.get(1)?,
                role: row.get(2)?,
                content: row.get(3)?,
                model_profile_id: row.get(4)?,
                metadata: parse_json_value(metadata_json),
                created_at: row.get(6)?,
            })
        })?;

        collect_rows(rows)
    }

    pub fn create_memory_item(&self, request: CreateMemoryItemRequest) -> Result<MemoryItemRecord> {
        let conn = self.open()?;
        let now = now_epoch_seconds();
        let tags_json = serde_json::to_string(&request.tags).context("failed to serialize tags")?;
        let metadata_json = to_json_string(request.metadata.as_ref())?;

        let record = MemoryItemRecord {
            id: new_id(),
            key: normalize_text(request.key, "memory_item"),
            value: request.value.trim().to_string(),
            source: normalize_optional_text(request.source),
            tags: request.tags,
            metadata: request.metadata,
            created_at: now,
            updated_at: now,
        };

        conn.execute(
            "INSERT INTO memory_items (id, key, value, source, tags_json, metadata_json, created_at, updated_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)",
            params![
                &record.id,
                &record.key,
                &record.value,
                &record.source,
                tags_json,
                metadata_json,
                record.created_at,
                record.updated_at,
            ],
        )
        .context("failed to insert memory item")?;

        Ok(record)
    }

    pub fn list_memory_items(&self) -> Result<Vec<MemoryItemRecord>> {
        let conn = self.open()?;
        let mut stmt = conn.prepare(
            "SELECT id, key, value, source, tags_json, metadata_json, created_at, updated_at
             FROM memory_items
             ORDER BY updated_at DESC
             LIMIT 100",
        )?;

        let rows = stmt.query_map([], |row| {
            let tags_json: String = row.get(4)?;
            let metadata_json: Option<String> = row.get(5)?;
            Ok(MemoryItemRecord {
                id: row.get(0)?,
                key: row.get(1)?,
                value: row.get(2)?,
                source: row.get(3)?,
                tags: serde_json::from_str(&tags_json).unwrap_or_default(),
                metadata: parse_json_value(metadata_json),
                created_at: row.get(6)?,
                updated_at: row.get(7)?,
            })
        })?;

        collect_rows(rows)
    }

    pub fn upsert_expert(&self, request: UpsertExpertRequest) -> Result<ExpertRecord> {
        let conn = self.open()?;
        let now = now_epoch_seconds();
        let id = normalize_text(request.id.unwrap_or_else(new_id), "expert");
        let metadata_json = to_json_string(request.metadata.as_ref())?;

        let existing_created_at = conn
            .query_row(
                "SELECT created_at FROM experts WHERE id = ?1",
                params![&id],
                |row| row.get::<_, i64>(0),
            )
            .unwrap_or(now);

        let record = ExpertRecord {
            id,
            name: normalize_text(request.name, "خبير جديد"),
            system_prompt: request.system_prompt.trim().to_string(),
            model_profile_id: normalize_optional_text(request.model_profile_id),
            metadata: request.metadata,
            created_at: existing_created_at,
            updated_at: now,
        };

        conn.execute(
            "INSERT INTO experts (id, name, system_prompt, model_profile_id, metadata_json, created_at, updated_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)
             ON CONFLICT(id) DO UPDATE SET
                name = excluded.name,
                system_prompt = excluded.system_prompt,
                model_profile_id = excluded.model_profile_id,
                metadata_json = excluded.metadata_json,
                updated_at = excluded.updated_at",
            params![
                &record.id,
                &record.name,
                &record.system_prompt,
                &record.model_profile_id,
                metadata_json,
                record.created_at,
                record.updated_at,
            ],
        )
        .context("failed to upsert expert")?;

        Ok(record)
    }

    pub fn list_experts(&self) -> Result<Vec<ExpertRecord>> {
        let conn = self.open()?;
        let mut stmt = conn.prepare(
            "SELECT id, name, system_prompt, model_profile_id, metadata_json, created_at, updated_at
             FROM experts
             ORDER BY updated_at DESC
             LIMIT 100",
        )?;

        let rows = stmt.query_map([], |row| {
            let metadata_json: Option<String> = row.get(4)?;
            Ok(ExpertRecord {
                id: row.get(0)?,
                name: row.get(1)?,
                system_prompt: row.get(2)?,
                model_profile_id: row.get(3)?,
                metadata: parse_json_value(metadata_json),
                created_at: row.get(5)?,
                updated_at: row.get(6)?,
            })
        })?;

        collect_rows(rows)
    }

    pub fn create_workspace_session(
        &self,
        request: CreateWorkspaceSessionRequest,
    ) -> Result<WorkspaceSessionRecord> {
        let conn = self.open()?;
        let now = now_epoch_seconds();
        let metadata_json = to_json_string(request.metadata.as_ref())?;

        let record = WorkspaceSessionRecord {
            id: new_id(),
            workspace_path: normalize_text(request.workspace_path, "unknown_workspace"),
            workspace_name: normalize_optional_text(request.workspace_name),
            active_file: normalize_optional_text(request.active_file),
            metadata: request.metadata,
            created_at: now,
            updated_at: now,
        };

        conn.execute(
            "INSERT INTO workspace_sessions (id, workspace_path, workspace_name, active_file, metadata_json, created_at, updated_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            params![
                &record.id,
                &record.workspace_path,
                &record.workspace_name,
                &record.active_file,
                metadata_json,
                record.created_at,
                record.updated_at,
            ],
        )
        .context("failed to insert workspace session")?;

        Ok(record)
    }

    pub fn list_workspace_sessions(&self) -> Result<Vec<WorkspaceSessionRecord>> {
        let conn = self.open()?;
        let mut stmt = conn.prepare(
            "SELECT id, workspace_path, workspace_name, active_file, metadata_json, created_at, updated_at
             FROM workspace_sessions
             ORDER BY updated_at DESC
             LIMIT 100",
        )?;

        let rows = stmt.query_map([], |row| {
            let metadata_json: Option<String> = row.get(4)?;
            Ok(WorkspaceSessionRecord {
                id: row.get(0)?,
                workspace_path: row.get(1)?,
                workspace_name: row.get(2)?,
                active_file: row.get(3)?,
                metadata: parse_json_value(metadata_json),
                created_at: row.get(5)?,
                updated_at: row.get(6)?,
            })
        })?;

        collect_rows(rows)
    }

    pub fn save_selected_model_profile(&self, profile_id: &str, profile: &Value) -> Result<()> {
        let conn = self.open()?;
        let now = now_epoch_seconds();
        let profile_json = serde_json::to_string(profile).context("failed to serialize selected model profile")?;

        conn.execute(
            "INSERT INTO selected_model_profile (id, profile_id, profile_json, updated_at)
             VALUES (1, ?1, ?2, ?3)
             ON CONFLICT(id) DO UPDATE SET
                profile_id = excluded.profile_id,
                profile_json = excluded.profile_json,
                updated_at = excluded.updated_at",
            params![profile_id, &profile_json, now],
        )
        .context("failed to save selected model profile")?;

        Ok(())
    }

    pub fn selected_model_profile(&self) -> Result<SelectedModelProfileRecord> {
        let conn = self.open()?;
        let result = conn.query_row(
            "SELECT profile_id, profile_json, updated_at FROM selected_model_profile WHERE id = 1",
            [],
            |row| {
                let profile_json: Option<String> = row.get(1)?;
                Ok(SelectedModelProfileRecord {
                    profile_id: row.get(0)?,
                    profile: parse_json_value(profile_json),
                    updated_at: row.get(2)?,
                })
            },
        );

        Ok(result.unwrap_or(SelectedModelProfileRecord {
            profile_id: None,
            profile: None,
            updated_at: None,
        }))
    }

    fn open(&self) -> Result<Connection> {
        Connection::open(self.db_path.as_ref()).with_context(|| {
            format!("failed to open memory db: {}", self.db_path.display())
        })
    }
}

fn collect_rows<T, F>(rows: rusqlite::MappedRows<'_, F>) -> Result<Vec<T>>
where
    F: FnMut(&rusqlite::Row<'_>) -> rusqlite::Result<T>,
{
    let mut records = Vec::new();
    for row in rows {
        records.push(row?);
    }
    Ok(records)
}

fn count_table(conn: &Connection, table_name: &str) -> Result<i64> {
    let sql = format!("SELECT COUNT(*) FROM {table_name}");
    conn.query_row(&sql, [], |row| row.get(0))
        .with_context(|| format!("failed to count table: {table_name}"))
}

fn normalize_text(value: String, fallback: &str) -> String {
    let normalized = value.trim().to_string();
    if normalized.is_empty() {
        fallback.to_string()
    } else {
        normalized
    }
}

fn normalize_optional_text(value: Option<String>) -> Option<String> {
    value
        .map(|item| item.trim().to_string())
        .filter(|item| !item.is_empty())
}

fn to_json_string(value: Option<&Value>) -> Result<Option<String>> {
    value
        .map(|item| serde_json::to_string(item).context("failed to serialize json value"))
        .transpose()
}

fn parse_json_value(value: Option<String>) -> Option<Value> {
    value.and_then(|item| serde_json::from_str(&item).ok())
}

fn preview_text(value: &str, max_chars: usize) -> String {
    let normalized = value.split_whitespace().collect::<Vec<_>>().join(" ");
    let mut preview: String = normalized.chars().take(max_chars).collect();

    if normalized.chars().count() > max_chars {
        preview.push_str("...");
    }

    preview
}

fn new_id() -> String {
    Uuid::new_v4().to_string()
}

fn now_epoch_seconds() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_secs() as i64)
        .unwrap_or_default()
}
