تمام يا مصطفى 🩵
الخلاصة المحددة: **إحنا دلوقتي عندنا UI شغال كبداية EDL، بس لازم نثبت الطريق قبل ما نكمل كود.** وأهم إضافة جديدة: **اختيار الموديل المحلي لازم يكون من الإعدادات، مش ثابت في الكود.**

---

## 1. اللي اتعمل فعليًا

### المشروع الحالي

اسم المشروع:

```yaml
name: logixa_edl_ai
```

وده خلاص يبقى الاسم الرسمي للنسخة الجديدة.

### الواجهة

اتعمل:

```text
Home Page
Workspace Page
Top Bar
Activity Bar
File Explorer
Editor Preview
Recent Workspaces
New Project
Open Folder
```

والـ Workspace بقى يفتح ملفات المشروع فعليًا، والشجرة ظهرت شبه VS Code.

### المشاكل اللي ظهرت واتصلحت جزئيًا

ظهر عندنا:

```text
GetX Obx crash
Workspace freeze
Google Fonts network error
Scrollbar controller error
```

واتفقنا إن التصميم لازم يتوحّد بين Home و Workspace، مش كل صفحة بشكل مختلف.

---

## 2. القرارات المعمارية النهائية

### القرار الأساسي

```text
Flutter = واجهة EDL / IDE / Control Center
Rust Engine = القلب المحلي الحقيقي
Local Model = يشتغل عند الطلب فقط
```

مش هنرجع لـ Python Engine، ولا LM Studio كأساس، ولا Ollama كأساس.

---

## 3. سياسة تشغيل الموديل المحلي

الموديل المحلي **مش هيشتغل مع فتح التطبيق**.

السياسة النهائية:

```text
المستخدم يفتح التطبيق
↓
Flutter يفتح الواجهة فقط
↓
Rust Engine ممكن يبقى جاهز وخفيف
↓
الموديل نفسه مش محمّل
↓
المستخدم يبعت رسالة
↓
لو local model enabled:
    شغّل الموديل المختار
    ابعت الرسالة + system prompt
    استقبل الرد
    خزّن المحادثة والذاكرة
    اقفل/فرّغ الموديل بعد الرد
```

يعني الإعدادات الأساسية تبقى:

```json
{
  "local_model_enabled": true,
  "selected_model_profile_id": "default_local_model",
  "auto_start_on_message": true,
  "keep_model_loaded": false,
  "unload_after_response": true,
  "allow_background_model": false
}
```

---

## 4. إضافة مهمة: اختيار الموديل من الإعدادات

دي لازم تدخل رسميًا في الخطة.

المستخدم لازم يقدر من Settings يعمل:

```text
اختيار ملف موديل GGUF
تغيير اسم الموديل
تحديد context size
تحديد threads
تحديد batch size
تحديد top_k
تفعيل/إيقاف الموديل المحلي
تحديد هل يقفل بعد كل رد ولا يفضل شغال
اختيار البروفايل النشط
```

شكل الـ model profile:

```json
{
  "id": "gemma_fast_local",
  "name": "Gemma Fast Local",
  "model_path": "/home/logixa/models/gemma.gguf",
  "context_size": 2048,
  "threads": 6,
  "batch_size": 256,
  "temperature": 0.7,
  "top_p": 0.9,
  "top_k": 64,
  "max_tokens": 512,
  "is_active": true
}
```

ممنوع نحط path ثابت للموديل في Dart أو Rust.

---

## 5. حالة الباكدجات الحالية

الباكدجات اللي عندك كويسة جدًا للمرحلة الحالية.

### موجود ومفيد

```text
get
get_storage
flutter_screenutil
intl
path
path_provider
file_picker
watcher
window_manager
multi_split_view
tabbed_view
super_context_menu
xterm
flutter_pty
flutter_code_editor
desktop_drop
drift
drift_flutter
uuid
logger
archive
mime
open_filex
```

### مهم جدًا

`file_picker` يكفينا حاليًا لاختيار موديل GGUF من الإعدادات.

يعني نقدر نعمل Step اختيار الموديل **بدون إضافة باكدجات جديدة**.

### ناقص لاحقًا

لما نبدأ ربط Rust Engine:

```bash
flutter pub add dio web_socket_channel
```

ولما نستخدم Drift بجد مع code generation:

```bash
flutter pub add --dev build_runner drift_dev
```

### ملاحظة مهمة عن google_fonts

خليه موجود، بس حاليًا **ما نعتمدش عليه في runtime** لأن حصل error لما حاول يحمل خط من الإنترنت.
الأفضل لاحقًا نحط الخطوط كـ assets محلية.

---

# الخطة بالترتيب

## Step 1 — تثبيت التصميم الموحد

الهدف:

```text
Home و Workspace يستخدموا نفس:
ActivityBar
TopBar
Panel/Card style
Text style
Spacing
Colors
```

ممنوع صفحة تبقى Dashboard style وصفحة تبقى VS Code style.

الناتج:

```text
تصميم موحد ومستقر
```

---

## Step 2 — Settings Page

نعمل صفحة إعدادات حقيقية:

```text
/settings
```

وفيها أقسام:

```text
General
Appearance
Local Model
Workspace
Memory
```

في المرحلة دي ننفذ بس:

```text
Local Model Settings
```

---

## Step 3 — Local Model Settings

نضيف:

```text
زر اختيار ملف موديل
عرض اسم الموديل
عرض مسار الموديل
تفعيل/إيقاف الموديل المحلي
context size
threads
batch size
max tokens
temperature
top_p
top_k
keep model loaded
unload after response
```

التخزين مؤقتًا بـ:

```text
GetStorage
```

لحد ما Rust Engine و SQLite يدخلوا.

---

## Step 4 — Model Profile System

بدل إعداد موديل واحد، نعمل Profiles:

```text
ModelProfile
```

مثلاً:

```text
Gemma Fast
Qwen Small
Dev Expert Model
Arabic Chat Model
```

المستخدم يقدر:

```text
Add Profile
Edit Profile
Set Active
Delete Profile
```

بس في الأول نبدأ بـ:

```text
Single active model profile
```

عشان ما نوسعش بدري.

---

## Step 5 — Workspace Tree Polish

الشجرة الحالية اشتغلت، بس محتاجة تتظبط:

```text
expand / collapse مضبوط
icons أوضح
ignore folders ثابت
right click لاحقًا
open file in editor
tabs لاحقًا
```

ونستخدم:

```text
super_context_menu
tabbed_view
multi_split_view
```

بس بالترتيب، مش كله مرة واحدة.

---

## Step 6 — Editor Tabs

نحوّل فتح الملف من preview واحد إلى tabs:

```text
Opened Files Tabs
Active File
Close Tab
Unsaved Indicator لاحقًا
```

هنا نستخدم:

```text
tabbed_view
flutter_code_editor
```

---

## Step 7 — Bottom Panel

نضيف Panel سفلي شبه VS Code:

```text
Terminal
Logs
Problems
Output
```

هنا نستفيد من:

```text
xterm
flutter_pty
logger
```

---

## Step 8 — Rust Engine Skeleton

نعمل مجلد:

```text
logixa_engine/
```

ونبدأ Rust Engine خفيف:

```text
health endpoint
status endpoint
settings endpoint
```

بعدها Flutter يكلمه.

هنا نضيف:

```bash
flutter pub add dio web_socket_channel
```

---

## Step 9 — Runtime Model Manager

في Rust:

```text
يقرأ active model profile
يشغل الموديل عند الرسالة
يبعت prompt
يرجع response
يقفل الموديل بعد الرد
```

ده مش دلوقتي قبل ما Settings و Profiles يثبتوا.

---

## Step 10 — Memory System

الذاكرة الأساسية لاحقًا تبقى:

```text
Rust + SQLite
```

وتخزن:

```text
conversations
messages
memory_items
selected_model_profile
experts
workspace_sessions
```

Firebase يفضل مؤجل كـ:

```text
backup / sync
```

مش core memory.

---

# الترتيب اللي نمشي عليه من دلوقتي

ننفذ بالضبط:

```text
1. توحيد التصميم نهائيًا
2. Settings Page
3. Local Model Settings
4. حفظ إعدادات الموديل بـ GetStorage
5. Model Profile واحد active
6. تحسين Workspace Tree
7. Editor Tabs
8. Bottom Terminal/Logs
9. Rust Engine Skeleton
10. Runtime Model Manager
```

## الخطوة الجاية مباشرة

**Step 2: نعمل Settings Page + Local Model Settings.**

في الخطوة دي مش هنشغل موديل.
بس هنخلي المستخدم يختار الموديل من الإعدادات ويتحفظ المسار والبروفايل.

ده أساس مهم جدًا قبل Rust Engine، عشان لما نيجي نشغل الموديل يبقى معروف هيشغل أنهي موديل وبأي إعدادات.







ملحوظات تم ذكرها من قبل GPT:
للعلم وليس للتنفيذ حاليا قابلة للنقاش بعد تنفيذ الخطوات الاساسية: 
### ما لم يتم تنفيذه عمدًا
- لم يتم تشغيل موديل محلي فعليًا.
- لم يتم إنشاء Rust Engine في هذه الخطوة.
- لم يتم استخدام Drift أو توليد Tables.
- لم يتم تعديل README.md.
- لم يتم إضافة Model Profiles متعددة؛ تم تنفيذ Single Active Model Profile فقط كما هو مذكور في README لتجنب التوسع المبكر.
