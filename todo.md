# todo.md — Logixa EDL AI Roadmap After Full Review

> آخر مراجعة: بعد رفع المشروع إلى GitHub وبعد تنفيذ Step 10.
>
> `README.md` هو المرجع الأساسي ولا يتم تعديله إلا بطلب صريح.
> `did.md` هو سجل التنفيذ.
> هذا الملف هو خطة التنفيذ العملية بعد مراجعة:
> - المحادثة والقرارات السابقة.
> - `README.md`.
> - `did.md`.
> - الكود الحالي على GitHub.
> - حالة الموديلات المحلية الموجودة على الجهاز.
>
> الهدف: نمشي بخطوات صغيرة، قابلة للاختبار، بدون تفريع، وبدون تشغيل موديل حقيقي قبل تثبيت الربط والذاكرة والشات.

---

# 0. الحالة الحالية المختصرة

## 0.1 المشروع

- اسم المشروع: `logixa_edl_ai`
- GitHub:
  - `https://github.com/Mostafa-Falcon/logixa_edl_ai`
- آخر نقطة ثابتة:
  - `step10-memory-system-audit`
- المنهج:
  - Flutter = واجهة EDL / IDE / Control Center.
  - Rust Engine = القلب المحلي الحقيقي.
  - الموديل المحلي لا يعمل مع فتح التطبيق.
  - الموديل يعمل فقط عند إرسال رسالة لو وضع الموديل المحلي مفعّل.
  - بعد الرد يتم تفريغ/إيقاف الموديل حسب سياسة التشغيل.

## 0.2 الموديلات المحلية الموجودة حاليًا

الموديلات موجودة محليًا داخل:

```text
models/gemma3_abliterated_v2/
```

وبداخلها:

```text
gemma-3-4b-it-abliterated-v2.q4_k_m.gguf
gemma-3-12b-it-abliterated-v2.q4_k_m.gguf
```

> تنبيه: مجلد `models/` وملفات `.gguf` لا تترفع إلى GitHub.

---

# 1. القرارات الجديدة بعد مراجعة الموديلات

## 1.1 استخدام 4B و12B

### Gemma 3 4B Q4_K_M

يكون البروفايل اليومي السريع:

```text
role = fast
use = chat / testing / normal tasks / light code help
```

### Gemma 3 12B Q4_K_M

يكون بروفايل جودة أعلى عند الحاجة فقط:

```text
role = quality
use = code review / architecture / hard reasoning / important decisions
```

## 1.2 ممنوع تحميل 12B دائمًا

سياسة 12B:

```text
keep_model_loaded = false
unload_after_response = true
load_policy = on_demand
ram_policy = conservative
```

السبب: الجهاز الحالي RAM حوالي 15GB، وتشغيل 12B لفترات طويلة ممكن يضغط الجهاز.

## 1.3 Smart Switching لاحقًا

لاحقًا بعد تثبيت الشات والذاكرة وتشغيل GGUF الحقيقي، نضيف:

```text
Runtime Model Router
```

وظيفته يختار بين:

```text
4B Fast
12B Quality
```

لكن هذا ليس للتنفيذ قبل Engine Client + Chat + Memory Save.

---

# 2. إعدادات Gemma 3 المطلوبة

## 2.1 Prompt Template

لازم يكون عندنا Prompt Template قابل للتعديل من الإعدادات أو من Runtime Profile.

القالب الأساسي لـ Gemma 3:

```text
<start_of_turn>user
{user_prompt}<end_of_turn>
<start_of_turn>model
```

ولو عندنا System Prompt، في المرحلة الحالية الأفضل إدخاله داخل بداية رسالة المستخدم بالشكل:

```text
<start_of_turn>user
{system_prompt}

{user_prompt}<end_of_turn>
<start_of_turn>model
```

> لاحقًا عند استخدام llama.cpp chat endpoint أو tokenizer chat template، نراجع هل القالب يتطبق من runtime ولا من السيرفر.

## 2.2 Sampling Settings

الإعدادات الأساسية التي يجب دعمها في ModelProfile:

```text
temperature = 1.0
top_k = 64
top_p = 0.95
repeat_penalty = 1.10 أو 1.20
presence_penalty = 0.10
```

حاليًا الموجود في الكود:

```text
temperature
top_k
top_p
```

الناقص ويجب إضافته قبل تشغيل GGUF الحقيقي:

```text
repeat_penalty
presence_penalty
prompt_template
model_role
load_policy
ram_policy
```

---

# 3. الوضع الحالي حسب README / did / الكود

## ✅ مكتمل مبدئيًا

- Home Page.
- Workspace Page.
- TopBar.
- ActivityBar.
- File Explorer.
- Editor Preview.
- Editor Tabs.
- Bottom Panel UI.
- Settings Page.
- Local Model Settings.
- Multiple Model Profiles.
- Dynamic System Prompt داخل Flutter.
- Rust Engine Skeleton.
- Runtime Manager lifecycle simulation.
- Memory System Skeleton داخل Rust.
- `todo.md` و `did.md`.

## 🟡 موجود جزئيًا

- Flutter Settings تحفظ في `GetStorage`.
- Rust Engine يحفظ في `logixa_engine_config.json`.
- لا يوجد Flutter Engine Client فعلي يربط الاتنين.
- `/runtime/chat` موجود لكنه lifecycle mock فقط.
- Memory endpoints موجودة، لكن Flutter لا يستخدمها بعد.
- ChatPage موجودة لكنها ليست Chat حقيقي.
- Terminal placeholder فقط.
- Extensions placeholder فقط.
- Editor preview وليس editor كامل.

## ⚪ Placeholder

- Search.
- Commands.
- Data Center.
- Real Terminal.
- Real Extensions.
- Real Chat.
- Real GGUF execution.
- Real Code Editor save/edit.

---

# 4. القاعدة التنفيذية من الآن

كل خطوة قادمة لازم تعمل الآتي:

```text
1. مراجعة README.md
2. مراجعة did.md
3. مراجعة todo.md
4. تنفيذ خطوة واحدة فقط
5. عدم لمس README.md إلا بطلب صريح
6. تحديث did.md بعد التنفيذ
7. لو تغيرت الخطة أو ظهر تعارض: نقف ونتناقش
8. بعد نجاح الفحص: commit + tag
```

---

# 5. الخطوات الصحيحة القادمة

## Step 11 — Flutter Engine Client + Engine Status Sync

**الأولوية:** P0  
**الهدف:** ربط Flutter بالـ Rust Engine بدون تشغيل موديل.

### المطلوب

إضافة Service:

```text
lib/app/data/services/engine_client_service.dart
```

يستخدم `dio` لقراءة:

```text
GET /health
GET /status
GET /settings
GET /runtime/status
GET /memory/status
```

### UI المطلوب

إظهار حالة الـ Engine في الواجهة:

```text
Engine Online / Offline
Runtime Stage
Model Loaded
Active Model Profile
Memory DB status
```

يفضل مبدئيًا في:

```text
TopBar
Settings
Bottom Panel / Output
```

### ممنوع في هذه الخطوة

```text
- تشغيل GGUF
- إرسال Chat
- مزامنة settings
- تعديل Memory
```

### الناتج المتوقع

Flutter يعرف هل Rust Engine شغال أم لا.

---

## Step 12 — Settings Sync To Rust

**الأولوية:** P0  
**الهدف:** توحيد مصدر الحقيقة تدريجيًا.

### المطلوب

عند حفظ إعدادات الموديل في Flutter:

```text
POST /runtime/profile
```

عند حفظ System Prompt:

```text
POST /runtime/system-prompt
```

عند فتح Settings:

```text
GET /settings
```

### القرار

بعد هذه الخطوة:

```text
Rust Engine = Source of Truth للإعدادات المهمة
Flutter GetStorage = UI Cache فقط
```

### يجب إضافة الحقول الناقصة إلى ModelProfile في Flutter وRust

```text
repeat_penalty
presence_penalty
prompt_template
model_role
load_policy
ram_policy
```

### ممنوع في هذه الخطوة

```text
- تشغيل GGUF
- Chat UI
- Memory auto-save
```

---

## Step 13 — Local Model Profiles Presets

**الأولوية:** P0  
**الهدف:** تجهيز بروفايلات 4B و12B من غير تشغيل حقيقي.

### المطلوب

إضافة زر أو Action في Settings:

```text
Create Recommended Gemma Profiles
```

ينشئ بروفايلين:

### 13.1 Gemma 4B Fast

```json
{
  "id": "gemma_4b_fast",
  "name": "Gemma 3 4B Fast",
  "role": "fast",
  "model_path": "models/gemma3_abliterated_v2/gemma-3-4b-it-abliterated-v2.q4_k_m.gguf",
  "context_size": 4096,
  "threads": 6,
  "batch_size": 256,
  "max_tokens": 512,
  "temperature": 1.0,
  "top_p": 0.95,
  "top_k": 64,
  "repeat_penalty": 1.1,
  "presence_penalty": 0.1,
  "keep_model_loaded": false,
  "unload_after_response": true,
  "load_policy": "on_demand",
  "ram_policy": "balanced"
}
```

### 13.2 Gemma 12B Quality

```json
{
  "id": "gemma_12b_quality",
  "name": "Gemma 3 12B Quality",
  "role": "quality",
  "model_path": "models/gemma3_abliterated_v2/gemma-3-12b-it-abliterated-v2.q4_k_m.gguf",
  "context_size": 4096,
  "threads": 6,
  "batch_size": 128,
  "max_tokens": 768,
  "temperature": 0.8,
  "top_p": 0.95,
  "top_k": 64,
  "repeat_penalty": 1.1,
  "presence_penalty": 0.1,
  "keep_model_loaded": false,
  "unload_after_response": true,
  "load_policy": "on_demand",
  "ram_policy": "conservative"
}
```

### مهم

- لو المسار غير موجود، يظهر Warning ولا يكراش.
- لا يتم رفع الموديلات إلى Git.
- لا يتم تشغيل أي موديل في هذه الخطوة.

---

## Step 14 — Real Chat Page Skeleton

**الأولوية:** P0  
**الهدف:** تحويل ChatPage من Placeholder إلى شاشة شات مبدئية.

### المطلوب

- Messages list.
- Text input.
- Send button.
- اختيار Profile يدوي أو استخدام active profile.
- إرسال الطلب إلى:

```text
POST /runtime/chat
```

### مؤقتًا

يعرض lifecycle response:

```text
runtime lifecycle is ready; actual GGUF execution adapter is not connected
```

### ممنوع

```text
- تشغيل GGUF الحقيقي
- Streaming
- Tools
```

---

## Step 15 — Auto-save Chat To Rust Memory

**الأولوية:** P0  
**الهدف:** أي رسالة شات تتحفظ في SQLite Memory.

### المطلوب

عند أول رسالة:

```text
POST /memory/conversations
```

ثم حفظ رسالة المستخدم:

```text
POST /memory/messages
```

ثم حفظ رد runtime/assistant:

```text
POST /memory/messages
```

مع metadata:

```text
workspace_path
active_model_profile_id
system_prompt_preview
runtime_stage
```

### الناتج

Memory System يبدأ يكون مستخدم فعليًا، مش مجرد endpoints.

---

## Step 16 — Data Center / Memory UI

**الأولوية:** P1  
**الهدف:** تشغيل زر Data Center بدل Placeholder.

### المطلوب

- صفحة Memory / Data Center.
- تعرض:
  - conversations.
  - messages count.
  - memory items.
  - experts.
  - workspace sessions.
  - selected model profile snapshot.
- تستخدم Rust Memory endpoints.

---

## Step 17 — Workspace Sessions Sync

**الأولوية:** P1  
**الهدف:** تسجيل استخدام الـ Workspace في Rust Memory.

### المطلوب

عند فتح Workspace:

```text
POST /memory/workspace-sessions
```

عند فتح ملف:

```text
update / add session metadata
```

### الناتج

Rust Memory تعرف آخر Workspace وملفات مفتوحة.

---

## Step 18 — Workspace Context Menu

**الأولوية:** P1  
**الهدف:** استخدام `super_context_menu` في الشجرة.

### المطلوب مبدئيًا

- Right click على File/Folder.
- Actions:
  - Open.
  - Copy path.
  - Reveal path.
  - Refresh.
- تأجيل Create/Rename/Delete لحين تثبيت الأمان.

---

## Step 19 — Real Terminal

**الأولوية:** P1  
**الهدف:** تحويل Terminal placeholder إلى طرفية حقيقية.

### المطلوب

- استخدام:
  - `xterm`
  - `flutter_pty`
- التشغيل داخل active workspace path.
- Stop / Restart terminal.
- لا يتم تشغيل أوامر تلقائيًا بدون طلب واضح.

---

## Step 20 — Real Code Editor

**الأولوية:** P1  
**الهدف:** تحويل Preview إلى محرر فعلي.

### المطلوب

- استخدام `flutter_code_editor`.
- Edit.
- Save.
- Unsaved indicator.
- حماية الملفات الكبيرة والـ binary.
- Log عند الحفظ.

---

## Step 21 — Runtime GGUF Adapter Planning

**الأولوية:** P2  
**الهدف:** تخطيط تشغيل GGUF الحقيقي قبل الكود.

### قرارات مطلوبة قبل التنفيذ

- هل هنستخدم:
  - `llama.cpp` process manager
  - أم Rust binding لاحقًا؟
- أين مسار `llama-server`؟
- هل runtime سيكون:
  - one-shot process per request
  - أم persistent server مع unload policy؟
- هل هنستخدم:
  - raw prompt template
  - أم chat completions template؟
- هل هنبدأ non-streaming ثم نضيف streaming؟

### القرار المبدئي المقترح

```text
llama.cpp process manager داخل Rust
non-streaming أولًا
on-demand load
unload_after_response افتراضيًا
```

---

## Step 22 — llama.cpp Adapter Prototype

**الأولوية:** P2  
**الهدف:** تشغيل موديل GGUF فعلي لأول مرة بشكل آمن.

### المطلوب

- تجربة 4B فقط أولًا.
- استخدام active model profile.
- بناء prompt template الصحيح لـ Gemma.
- تطبيق:
  - temperature.
  - top_k.
  - top_p.
  - repeat_penalty.
  - presence_penalty.
- حفظ الرد في Memory.
- لا تشغيل 12B في أول تجربة.

### شروط النجاح

```text
- لا Freeze
- لا بقاء موديل محمل بعد الرد إلا لو مفعّل
- الرد يرجع إلى Chat UI
- memory تحفظ الرسائل
```

---

## Step 23 — Streaming Response

**الأولوية:** P2  
**الهدف:** الرد يظهر تدريجيًا في Chat.

### المطلوب

- Rust stream endpoint أو WebSocket/SSE.
- Flutter يستقبل tokens.
- Stop generation button.
- حفظ الرسالة النهائية فقط في Memory.

---

## Step 24 — Runtime Model Router

**الأولوية:** P2  
**الهدف:** الاختيار الذكي بين 4B و12B.

### المطلوب

- Manual mode:
  - Fast.
  - Quality.
- Auto mode لاحقًا:
  - لو prompt بسيط → 4B.
  - لو prompt صعب أو كود كبير → 12B.
- ممنوع تحميل 4B و12B معًا في هذه المرحلة.

---

## Step 25 — Extensions System Planning

**الأولوية:** P2  
**الهدف:** تحويل زر Extensions إلى نظام قابل للتوسع.

### المطلوب قبل التنفيذ

- تعريف extension manifest.
- أماكن التخزين.
- الصلاحيات.
- هل extension Flutter-only أم Rust tools أيضًا؟
- منع تشغيل كود خارجي بدون موافقة.

---

# 6. Cleanup قبل تشغيل موديل حقيقي

## C1 — README Consistency Review

**الأولوية:** P1  
**يحتاج إذن صريح لتعديل README**

README يحتوي على خطة قديمة جزئيًا وبعض الترتيب لا يعكس ما تم بعد Step 10.  
لا يتم تعديل README إلا لو مصطفى طلب ذلك صراحة.

## C2 — Flutter Linux Close Warning

**الأولوية:** P2

ظهر تحذير عند الإغلاق:

```text
FlutterEngineRemoveView returned kInvalidArguments
```

ليس blocker طالما يظهر بعد الضغط على إغلاق فقط، لكن يتم تنظيفه لاحقًا.

## C3 — GitHub Hygiene

**الأولوية:** P0 مستمر

- لا ترفع:
  - `models/`
  - `*.gguf`
  - `logixa_engine_config.json`
  - `logixa_engine_memory.sqlite`
  - `target/`
  - `build/`

## C4 — Tests / Smoke Checks

بعد كل خطوة:

```bash
flutter pub get
flutter analyze
flutter run -d linux
```

ولـ Rust:

```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

واختبار endpoints حسب الخطوة.

---

# 7. الترتيب المختصر للتنفيذ

```text
Step 11  Flutter Engine Client + Engine Status Sync
Step 12  Sync Settings/System Prompt/Profile to Rust + add missing model fields
Step 13  Recommended Gemma 4B/12B Profiles
Step 14  Real Chat Page Skeleton
Step 15  Auto-save Chat to Rust Memory
Step 16  Data Center / Memory UI
Step 17  Workspace Sessions Sync
Step 18  Workspace Context Menu
Step 19  Real Terminal
Step 20  Real Code Editor
Step 21  Runtime GGUF Adapter Planning
Step 22  llama.cpp Adapter Prototype with 4B only
Step 23  Streaming Response
Step 24  Runtime Model Router 4B/12B
Step 25  Extensions System Planning
```

---

# 8. قاعدة منع اللخبطة

لا يتم تنفيذ Step 22 أو تشغيل أي موديل GGUF حقيقي قبل اكتمال:

```text
Step 11
Step 12
Step 14
Step 15
```

لأن تشغيل الموديل قبل وجود Engine Client + Chat + Memory Save هيخلينا نكرر نفس لخبطة المشاريع القديمة.

