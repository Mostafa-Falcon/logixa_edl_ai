# Logixa EDL AI

> Current reference after Review 02 — Documentation Reconciliation.
>
> This README describes the **current architecture and working direction** after the project reached real Flutter + Rust + llama-server execution through Step 24.

---

## 1. Project Identity

```yaml
name: logixa_edl_ai
repo: https://github.com/Mostafa-Falcon/logixa_edl_ai
current_phase: Audit & Roadmap Reset
latest_confirmed_feature_step: Step 24 — Manual Runtime Model Router 4B/12B
```

Logixa EDL AI is a local AI development/control environment.

The product direction is:

```text
Flutter Desktop App = EDL / IDE / Control Center
Rust Engine         = local runtime, memory, model orchestration
GGUF Models         = user-selected local models through Settings
llama-server        = runtime backend managed by Rust
```

---

## 2. Core Architecture Decisions

### 2.1 Flutter responsibility

Flutter is responsible for:

```text
- UI / UX
- Workspace navigation
- Settings and model profiles
- Chat interface
- Runtime status display
- Data Center / Memory UI
- Diagnostics and exports
```

Flutter must not contain hidden model paths or hidden prompts.

### 2.2 Rust Engine responsibility

Rust Engine is responsible for:

```text
- health/status endpoints
- runtime state
- model profile sync
- llama-server process management
- chat and streaming endpoints
- memory persistence through SQLite
- runtime safety rules
```

### 2.3 Local model policy

The local model must not load automatically when the app opens.

Policy:

```text
User opens app
↓
Flutter UI starts
↓
Rust Engine may be started lightly
↓
No GGUF model is loaded yet
↓
User sends a message
↓
If local model mode is enabled:
  use the active model profile selected by the user
  start llama-server if needed
  send prompt
  stream or return response
  save final message when applicable
  unload after response by default
```

Default runtime policy:

```json
{
  "local_model_enabled": true,
  "auto_start_on_message": true,
  "keep_model_loaded": false,
  "unload_after_response": true,
  "allow_background_model": false
}
```

---

## 3. Hard Rules

These rules are part of the project contract:

```text
1. No hardcoded GGUF model paths in Dart or Rust.
2. Model path comes only from the user-selected Model Profile.
3. No hidden/default System Prompt in Dart, Rust, JSON config, or examples.
4. If System Prompt is empty, no system prompt is applied.
5. 4B and 12B must not be loaded at the same time.
6. 12B is allowed only as a user-selected Quality profile, with conservative policy.
7. Auto Router is deferred until diagnostics and evaluation exist.
8. Each implementation step must be small, testable, and logged in did.md.
9. README.md, did.md, and todo.md must stay synchronized after this review.
10. If the user adds a note during work, record it as a note without branching unless it is a blocker.
```

---

## 4. Current Implemented Capabilities

The project currently includes:

```text
✅ Unified Flutter shell / control center
✅ Home / Workspace / Settings / Chat / Data Center modules
✅ Workspace file tree
✅ Workspace sessions sync
✅ Workspace context menu
✅ Real terminal through xterm + flutter_pty
✅ Real code editor with edit/save protection
✅ Local model settings
✅ Multiple model profiles
✅ Active model profile sync to Rust
✅ Dynamic user-saved system prompt
✅ Rust Engine skeleton and status endpoints
✅ Rust memory skeleton with SQLite
✅ Chat page connected to runtime
✅ llama-server adapter managed by Rust
✅ Real GGUF inference
✅ Streaming response
✅ Stop generation control
✅ Manual Runtime Router: Fast / 4B and Quality / 12B
✅ Chat export for diagnostics
✅ Hidden/default system prompt removed
```

---

## 5. Current Known Risks

```text
1. Documentation was behind the implementation before Review 02.
2. Some files have grown too large and need hygiene splitting.
3. Runtime diagnostics are not yet strong enough for comparing models.
4. Model quality cannot be judged reliably without fixed test prompts and exported settings.
5. Extensions must not be implemented before permission/safety planning.
```

Files to review in the hygiene pass:

```text
lib/app/data/services/engine_client_service.dart
lib/app/modules/settings/controllers/settings_controller.dart
lib/app/modules/chat_page/controllers/chat_page_controller.dart
logixa_engine/src/runtime.rs
```

---

## 6. Current Roadmap From This Point

### Review 02 — Documentation Reconciliation

Status: current step.

Goal:

```text
- Rewrite README.md to describe the real current architecture.
- Rewrite todo.md to define the next roadmap from the current state.
- Add a Summary Index to did.md without deleting execution history.
```

### Step 25 — Codebase Hygiene Pass

Goal: improve maintainability without changing behavior.

Scope:

```text
- Split large services/controllers where needed.
- Keep text in AppStrings.
- Verify no hidden prompts or model paths.
- Verify file permissions.
- Verify ignored runtime files are not tracked.
```

### Step 26 — Runtime Diagnostics Panel

Goal: make model/runtime behavior easy to inspect.

Scope:

```text
- Active model profile details
- llama-server path/status
- runtime stage
- last error
- sampling settings
- prompt template
- system prompt state
- fixed test prompt button
- copy diagnostic report button
```

### Step 27 — Model Evaluation Harness

Goal: compare models using stable prompts.

Scope:

```text
- Fixed test prompt set
- Fast vs Quality comparison
- response time
- runtime stage
- final response export
- no automatic model switching
```

### Step 28 — Extensions System Planning

Goal: plan extensions safely before implementation.

Scope:

```text
- extension manifest
- storage location
- permissions
- Flutter-only vs Rust tool extensions
- enable/disable policy
- logging
- no external code execution without explicit approval
```

---

## 7. Execution Workflow

Every implementation step must follow this order:

```text
1. Review README.md
2. Review did.md
3. Review todo.md
4. Define one exact target
5. Modify only the necessary files
6. Update did.md
7. Run checks
8. Commit + tag after success
```

Standard checks:

```bash
flutter analyze
flutter run -d linux

cd logixa_engine
cargo fmt
cargo check
cargo run
```

Run Rust checks only when Rust files are touched.

---

## 8. GitHub Hygiene

Never commit:

```text
models/
*.gguf
logixa_engine/logixa_engine_config.json
logixa_engine/logixa_engine_memory.sqlite
logixa_engine/target/
build/
.dart_tool/
```

If a ZIP or generated artifact appears in the project root, inspect before committing.

---

## 9. Deferred Work

These are intentionally deferred:

```text
- Auto model router
- Long 12B stress testing
- Extensions implementation
- External tools execution
- Packaging/release installer
- Cloud sync
- Firebase backup
- Advanced memory search
```

They should only be pulled forward after discussion.
