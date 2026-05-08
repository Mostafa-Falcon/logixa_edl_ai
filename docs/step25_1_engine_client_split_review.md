# Step 25.1 — Engine Client Split Review

> Codebase Hygiene Pass — review only.
>
> No Dart/Rust behavior changes in this step.

## Goal

Review `lib/app/data/services/engine_client_service.dart` before splitting it, and define a safe refactor path that preserves behavior.

## Current Problem

`EngineClientService` has become a multi-responsibility service. It currently acts as:

```text
- Engine health/status polling client
- Local Rust Engine process controller
- Runtime profile/settings sync client
- Runtime chat client
- Streaming chat client
- Stop generation client
- Memory write/read client
- Memory dashboard client
- HTTP parsing/error utility holder
```

This makes the file harder to maintain and increases the risk of breaking runtime chat, memory, or process management when adding new features.

## Hard Rules For Refactor

```text
1. Behavior must not change.
2. No endpoint changes.
3. No Rust changes in the first split step.
4. Existing callers should keep using EngineClientService initially.
5. EngineClientService should become a facade over smaller internal clients.
6. flutter analyze must pass after each small split.
7. Split one concern at a time; do not move everything at once.
```

## Proposed Target Structure

```text
lib/app/data/services/engine/
  engine_http_core.dart
  engine_health_client.dart
  engine_process_client.dart
  runtime_chat_client.dart
  memory_client.dart
  settings_sync_client.dart
```

### `engine_http_core.dart`

Shared Dio instance, base URL, response helpers, and friendly error formatting.

### `engine_health_client.dart`

Read-only engine/runtime status operations:

```text
GET /health
GET /status
GET /settings
GET /runtime/status
```

### `engine_process_client.dart`

Local process management only:

```text
start local Rust Engine
stop local Rust Engine
stop managed process
fallback kill by port
```

### `settings_sync_client.dart`

Settings/profile sync only:

```text
POST /runtime/profile
POST /runtime/system-prompt
```

### `runtime_chat_client.dart`

Runtime chat only:

```text
POST /runtime/chat
POST /runtime/chat/stream
POST /runtime/stop-generation
```

### `memory_client.dart`

Memory API only:

```text
POST /memory/conversations
POST /memory/messages
POST /memory/workspace-sessions
GET  /memory/status
GET  /memory/conversations
GET  /memory/messages
GET  /memory/items
GET  /memory/experts
GET  /memory/workspace-sessions
GET  /memory/selected-model-profile
```

## Safe Implementation Order

### Step 25.2 — Extract HTTP Core Only

Move shared Dio setup and parsing helpers into a private/internal helper while keeping public `EngineClientService` methods unchanged.

Expected files:

```text
lib/app/data/services/engine_client_service.dart
lib/app/data/services/engine/engine_http_core.dart
```

### Step 25.3 — Extract Memory Client

Move memory-specific calls to `memory_client.dart` because they are isolated from chat streaming and process control.

Expected files:

```text
lib/app/data/services/engine_client_service.dart
lib/app/data/services/engine/memory_client.dart
```

### Step 25.4 — Extract Runtime Chat Client

Move non-streaming chat, streaming chat, and stop generation after memory split is stable.

Expected files:

```text
lib/app/data/services/engine_client_service.dart
lib/app/data/services/engine/runtime_chat_client.dart
```

### Step 25.5 — Extract Settings Sync Client

Move `/runtime/profile` and `/runtime/system-prompt` sync.

### Step 25.6 — Extract Process Client Last

Move process start/stop last because it touches local OS process behavior and needs careful manual testing.

## Acceptance Checklist

For every split step:

```bash
flutter analyze
flutter run -d linux
```

Manual checks:

```text
- Engine status still updates.
- Local Engine start/stop still works if touched.
- Chat still sends and receives streaming response if runtime touched.
- Memory dashboard still loads if memory touched.
- Settings save still syncs if settings touched.
```

## Current Decision

Step 25.1 is review/documentation only.

Next exact implementation step:

```text
Step 25.2 — Extract Engine HTTP Core
```

No feature work should start before this hygiene sequence is complete enough to reduce file-size risk.
