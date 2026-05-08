# todo.md — Logixa EDL AI Roadmap After Review 02

> آخر مراجعة: بعد Step 24 — Manual Runtime Model Router 4B/12B.
>
> المرحلة الحالية: **Audit & Roadmap Reset**.
>
> الهدف: نكمّل من الحالة الحقيقية للكود، مش من خطة قديمة.

---

## 0. Workflow Rules

```text
1. كل خطوة تبدأ بمراجعة README.md ثم did.md ثم todo.md.
2. خطوة واحدة فقط في كل مرة.
3. لا تعديل خارج النطاق.
4. لا Features جانبية أثناء الصيانة.
5. أي ملحوظة من مصطفى أثناء العمل تضاف كـ Note، ولا تغيّر المسار إلا لو اتناقشنا أو كانت Blocker.
6. لا hardcoded model paths.
7. لا hidden/default system prompt.
8. لا تشغيل كود خارجي أو Extensions بدون موافقة صريحة.
9. did.md يتحدث بعد كل خطوة.
10. بعد النجاح: checks ثم commit/tag/push.
```

---

## 1. Current Stable State

Latest confirmed implemented feature:

```text
Step 24 — Manual Runtime Model Router 4B/12B
```

Current system summary:

```text
Flutter = EDL / IDE / Control Center
Rust Engine = local runtime and memory
llama-server = GGUF backend managed by Rust
Model Profile = only source of model path/settings
System Prompt = user-saved only, empty means not applied
```

Completed functional areas:

```text
✅ Settings + Local Model Settings
✅ Multiple Model Profiles
✅ Settings sync to Rust
✅ Chat Page
✅ Chat export
✅ Rust Engine skeleton
✅ Memory skeleton
✅ Data Center basic UI
✅ Workspace sessions sync
✅ Workspace context menu
✅ Real Terminal
✅ Real Code Editor
✅ llama-server GGUF adapter
✅ Real GGUF inference
✅ Streaming response
✅ Manual Fast/Quality router
✅ hidden/default system prompt removed
```

---

## 2. Current Risk List

```text
R1. Large files are growing and need splitting.
R2. Documentation history is long and needs index/summary.
R3. Diagnostics are not enough for model comparison.
R4. Memory save/export needs structured verification.
R5. Extensions are still unplanned and must stay deferred.
```

---

# 3. Next Roadmap

## Review 02 — Documentation Reconciliation

**Status:** current documentation step.

**Goal:** align documentation with current reality.

**Files:**

```text
README.md
todo.md
did.md
```

**Required output:**

```text
README.md = current vision and architecture
todo.md = new roadmap from current state
did.md = Summary Index + preserve execution history
```

**Forbidden:**

```text
- No Dart code changes
- No Rust code changes
- No feature work
```

**Checks:**

```bash
git diff -- README.md todo.md did.md
```

---

## Step 25 — Codebase Hygiene Pass

**Priority:** P0

**Goal:** reduce future confusion and keep code maintainable without changing behavior.

### 25.1 Engine Client split review

Current concern:

```text
lib/app/data/services/engine_client_service.dart
```

Possible split:

```text
engine_health_client.dart
engine_process_client.dart
runtime_chat_client.dart
memory_client.dart
settings_sync_client.dart
```

Scope rule: split only if it preserves current behavior and keeps imports clear.

### 25.2 Rust runtime split review

Current concern:

```text
logixa_engine/src/runtime.rs
```

Possible split later:

```text
runtime_manager.rs
llama_server_adapter.rs
runtime_chat.rs
runtime_stream.rs
```

Step 25 may start with analysis and only split the safest part.

### 25.3 Strings and UI consistency

Check:

```text
- User-facing strings should live in AppStrings.
- No hidden system prompt text anywhere.
- No hidden model path text anywhere.
- No accidental chmod executable on source files.
```

### Acceptance Criteria

```text
flutter analyze passes
cargo check passes if Rust touched
git status clean after commit
behavior unchanged
```

---

## Step 26 — Runtime Diagnostics Panel

**Priority:** P0

**Goal:** understand runtime/model behavior without guessing.

Required UI:

```text
- active model profile name/id/path
- role: fast/quality
- llama-server binary path
- server_url
- runtime stage
- model_loaded
- last_error
- system_prompt_saved
- system_prompt_chars
- sampling settings
- prompt_template
```

Required actions:

```text
- Test model button
- Copy diagnostics report
```

Forbidden:

```text
- No auto router
- No default prompt
- No hidden model selection
```

---

## Step 27 — Model Evaluation Harness

**Priority:** P1

**Goal:** compare local models using repeatable tests.

Required:

```text
- fixed prompt list
- run selected prompt against active profile
- compare Fast vs Quality manually
- record duration
- record runtime stage
- export result
```

Forbidden:

```text
- No automatic model switching
- No background benchmark loops
- No long 12B stress run without explicit approval
```

---

## Step 28 — Extensions System Planning

**Priority:** P1

**Goal:** plan extensions before implementation.

Required planning topics:

```text
- extension manifest format
- storage location
- permissions
- enable/disable flow
- Flutter-only extensions
- Rust tool extensions
- logging/audit trail
- security rule: no external code execution without explicit approval
```

Output should be a Markdown plan only.

---

# 4. Deferred / Later

```text
- Auto Runtime Router
- Advanced memory search
- Workspace project indexing
- Create/Rename/Delete from context menu
- Real Extensions implementation
- Packaging / installer
- Cloud backup or sync
- Long 12B performance tuning
```

---

# 5. Smoke Checks

For Flutter steps:

```bash
flutter analyze
flutter run -d linux
```

For Rust steps:

```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

For runtime chat:

```bash
export LOGIXA_LLAMA_SERVER_BIN="$HOME/logixa_ai/tools/llama.cpp/build/bin/llama-server"
```

Then test from UI or endpoint.

---

# 6. Git Hygiene

Do not commit:

```text
models/
*.gguf
logixa_engine/logixa_engine_config.json
logixa_engine/logixa_engine_memory.sqlite
logixa_engine/target/
build/
.dart_tool/
*.zip
```

If a file appears unexpectedly in `git status --short`, stop and inspect it before committing.
