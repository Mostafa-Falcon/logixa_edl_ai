# todo.md — Logixa EDL AI Post-Step 10 Audit

## الهدف من الملف
هذا الملف هو نتيجة مراجعة ما بعد Step 10. الهدف منه توثيق:

- ما تم تنفيذه فعليًا.
- ما هو مكتمل مبدئيًا.
- ما هو موجود كواجهة فقط أو Placeholder.
- ما يحتاج ربط بين Flutter و Rust Engine.
- الخطوات الناقصة المقترحة بعد Step 10.

> ملاحظة مهمة: `README.md` هو المرجع، ولم يتم تعديله في هذه المراجعة. هذا الملف يترجم الفجوات الحالية إلى خطوات تنفيذية.

---

## نطاق المراجعة
تمت مقارنة الملفات المتاحة في النسخة المرفوعة مع:

- `README.md`
- `did.md`
- كود Flutter داخل `lib/`
- كود Rust داخل `logixa_engine/`

### ملاحظة على النسخة المرفوعة
النسخة التي تمت مراجعتها لا تحتوي على ملفات جذرية مثل:

- `pubspec.yaml`
- `pubspec.lock`
- platform folders مثل `linux/`

لذلك تقييم باكدجات Flutter اعتمد على السجل السابق والملفات البرمجية الموجودة، وليس على فحص `pubspec.yaml` داخل هذه النسخة.

---

# 1. ملخص الحالة الحالية

## ✅ شغال فعليًا / مكتمل مبدئيًا

### Flutter UI foundation
- `CorePage` موجود ويوحد الـ TopBar والخلفية.
- `TopBar` موجود ومقسم إلى Sections.
- `AppActivityBar` reusable ومستخدم في Home / Settings / Workspace.
- ألوان، أحجام، خطوط، Theme، وReusable Widgets موجودة.

### Home / Workspaces
- إنشاء مشروع جديد موجود.
- فتح مجلد مشروع موجود.
- حفظ Active Workspace في `GetStorage` موجود.
- Recent Workspaces موجودة.
- منع تكرار المشاريع حسب الاسم أو المسار موجود.
- إنشاء structure مبدئي للمشروع الجديد موجود.

### Settings / Local Model
- صفحة `/settings` موجودة.
- اختيار موديل `.gguf` من الواجهة موجود.
- إعدادات التشغيل موجودة:
  - `context_size`
  - `threads`
  - `batch_size`
  - `max_tokens`
  - `temperature`
  - `top_p`
  - `top_k`
  - `keep_model_loaded`
  - `unload_after_response`
  - `auto_start_on_message`
  - `allow_background_model`
- التخزين المحلي المؤقت بـ `GetStorage` موجود.
- `ModelProfileModel` موجود.
- Multiple Model Profiles موجودة بشكل مبدئي.

### System Prompt
- System Prompt ديناميكي من Flutter Settings موجود.
- حفظه واستعادة الافتراضي موجودين.
- Rust Engine يقبل System Prompt من `/runtime/system-prompt`.
- `/runtime/chat` يقرأ System Prompt ويعيد معلومات تؤكد تطبيقه.

### Workspace
- صفحة Workspace موجودة.
- Explorer موجود.
- فتح الملفات النصية موجود.
- Tabs موجودة.
- منع تكرار فتح نفس الملف في Tabs موجود.
- إغلاق Tab موجود.
- Bottom Panel موجود.
- Logs / Problems / Output موجودة بشكل مبدئي.

### Rust Engine
- `logixa_engine/` موجود.
- `/health` موجود.
- `/status` موجود.
- `/settings` موجود.
- Config file موجود ويتولد عند الحاجة.
- Runtime Manager مبدئي موجود.
- `/runtime/status` موجود.
- `/runtime/profile` موجود.
- `/runtime/chat` موجود كـ lifecycle simulation.
- `/runtime/unload` موجود.
- SQLite Memory Skeleton موجود.
- Memory endpoints موجودة.

---

## 🟡 موجود جزئيًا / يحتاج ربط

### Flutter ↔ Rust Engine
- باكدجات `dio` و`web_socket_channel` تم تجهيزها سابقًا، لكن لا يوجد Flutter Engine Client فعلي في الكود الحالي.
- Settings في Flutter تحفظ في `GetStorage` فقط.
- Rust Engine يحفظ في `logixa_engine_config.json` فقط.
- لا يوجد Sync تلقائي بين Flutter Settings و Rust Config.

### Runtime Model Manager
- دورة التشغيل موجودة كـ lifecycle فقط.
- لا يوجد تشغيل GGUF فعلي.
- لا يوجد `llama.cpp` adapter.
- لا يوجد فحص حقيقي لوجود ملف الموديل على الجهاز قبل قبول البروفايل.

### Memory System
- Rust Memory endpoints موجودة.
- Flutter لا يستخدمها بعد.
- `/runtime/chat` لا ينشئ Conversation ولا Messages تلقائيًا.
- لا توجد شاشة Memory/Data Center فعلية.
- لا يوجد semantic search أو embeddings.

### Workspace Editor
- المعاينة النصية موجودة.
- لا يوجد تحرير فعلي للملفات.
- لا يوجد Save.
- لا يوجد Unsaved Indicator.
- `flutter_code_editor` موجود في الخطة لكنه غير مستخدم فعليًا في Workspace Editor الحالي.

### Bottom Panel / Terminal
- Bottom Panel موجود.
- Terminal مجرد Placeholder.
- `xterm` و`flutter_pty` غير مستخدمين فعليًا.

### Extensions
- زر Extensions وPanel موجودين.
- لا يوجد Extension manifest.
- لا يوجد install/uninstall.
- لا يوجد plugin system فعلي.

### Chat
- `ChatPage` موجودة كصفحة مولدة/Placeholder.
- `ChatPageController` ما زال يحتوي TODO.
- لا يوجد UI Chat حقيقي.
- لا يوجد ربط بـ `/runtime/chat`.

---

## ⚪ Placeholder / غير فعال حاليًا

- TopBar Search button.
- TopBar Commands button.
- Home Data Center quick action.
- Home Sidebar عناصر Chat / Terminal / Data.
- Workspace Search activity button.
- Workspace Data activity button.
- Terminal الحقيقي.
- Extensions system الحقيقي.
- Chat screen الحقيقي.

---

# 2. مقارنة مباشرة مع README.md و did.md

## Step 1 — تثبيت التصميم الموحد
**الحالة:** 🟡 مكتمل مبدئيًا لكن يحتاج تثبيت نهائي.

تم تنفيذ CorePage وActivityBar وTopBar وReusable Widgets، لكن بعض الصفحات أو الأزرار ما زالت Placeholder، خصوصًا ChatPage وData/Terminal.

### الناقص
- توحيد صفحات Placeholder لاحقًا بدل النص الافتراضي.
- تثبيت Pattern واضح لكل صفحة جديدة:
  - `View`
  - `Controller`
  - `Sections`
  - `Reusable widgets`

---

## Step 2 — Settings Page
**الحالة:** ✅ مكتمل مبدئيًا.

صفحة Settings موجودة وتعمل، لكنها حاليًا مركزة على Local Model فقط.

### الناقص لاحقًا
- General section.
- Appearance section.
- Workspace section.
- Memory section.

---

## Step 3 — Local Model Settings
**الحالة:** ✅ مكتمل مبدئيًا في Flutter.

الإعدادات المطلوبة موجودة، و`top_k` تم إضافته.

### الناقص
- مزامنة الإعدادات مع Rust Engine.
- التحقق من مسار ملف الموديل من Rust.
- إرسال الإعدادات عند runtime تلقائيًا.

---

## Step 4 — Model Profile System
**الحالة:** ✅ مكتمل مبدئيًا في Flutter.

Multiple Profiles موجودة، والإضافة/التعديل/الحذف/التعيين كنشط موجودة.

### الناقص
- مزامنة البروفايل النشط مع `/runtime/profile` تلقائيًا.
- حفظ البروفايلات في Rust Memory لاحقًا بدل Flutter فقط.
- منع حذف/تعديل بروفايل مستخدم حاليًا في Session نشطة، لاحقًا.

---

## Step 5 — Workspace Tree Polish
**الحالة:** 🟡 مكتمل مبدئيًا.

الشجرة تعمل، والطي/التوسيع/التحديث موجودين، والقراءة تتم بطريقة آمنة نسبيًا.

### الناقص
- Context menu باستخدام `super_context_menu`.
- Create / Rename / Delete للملفات والمجلدات.
- File search داخل المشروع.
- استخدام `watcher` لتحديث الشجرة عند تغيير الملفات.
- تمييز الملفات المفتوحة/المعدلة لاحقًا بشكل أقوى.

---

## Step 6 — Editor Tabs
**الحالة:** 🟡 مكتمل مبدئيًا.

Tabs موجودة وتعمل للفتح والإغلاق والتنقل.

### الناقص
- استخدام `flutter_code_editor` كمحرر حقيقي.
- Edit / Save.
- Unsaved indicator.
- حفظ حالة Tabs في Workspace Session.

---

## Step 7 — Bottom Panel
**الحالة:** 🟡 UI مكتمل مبدئيًا.

Tabs السفلي موجود: Terminal / Logs / Problems / Output.

### الناقص
- Terminal حقيقي باستخدام `xterm` و`flutter_pty`.
- Logs من Rust Engine.
- Problems حقيقية من analyzer/build output.
- Output panel مربوط بعمليات فعلية.

---

## Step 8 — Rust Engine Skeleton
**الحالة:** ✅ مكتمل مبدئيًا.

Endpoints الأساسية موجودة، والـ Engine اشتغل محليًا حسب لوجات المستخدم السابقة.

### الناقص
- Flutter Engine Client.
- تشغيل/إيقاف الـ Engine من Flutter لاحقًا إن لزم.
- Handling أفضل لو البورت مستخدم.

---

## Step 9 — Runtime Model Manager
**الحالة:** 🟡 Runtime Lifecycle فقط.

Runtime endpoints موجودة، لكن تشغيل GGUF الحقيقي غير موجود عمدًا.

### الناقص
- `llama.cpp` process adapter.
- بناء launch args من Model Profile.
- Start/Stop process فعليًا.
- Health check للـ model server/adapter.
- Streaming response.
- ربط `/runtime/chat` بالذاكرة تلقائيًا.

---

## Step 9.1 — Dynamic System Prompt
**الحالة:** 🟡 مكتمل محليًا لكن غير مربوط من Flutter إلى Rust تلقائيًا.

Flutter يحفظ System Prompt محليًا، وRust يقبل System Prompt، لكن لا يوجد client يزامنهم.

### الناقص
- عند حفظ System Prompt من Flutter، يتم POST إلى `/runtime/system-prompt`.
- عند فتح Settings، يتم قراءة Rust settings أو توضيح مصدر الحقيقة.
- Markdown import/export مؤجل.

---

## Step 10 — Memory System
**الحالة:** 🟡 Skeleton موجود في Rust.

SQLite والجداول والـ endpoints موجودة.

### الناقص
- Flutter Memory Client.
- Data Center UI.
- حفظ محادثات runtime تلقائيًا.
- ربط Workspace sessions بالواجهة.
- حذف/تعديل/بحث للذاكرة.
- Migration/versioning واضح للجداول.

---

# 3. أهم الفجوات المعمارية الحالية

## 3.1 مصدر الحقيقة للإعدادات غير موحد
حاليًا عندنا مصدرين:

- Flutter `GetStorage`
- Rust `logixa_engine_config.json`

لازم نقرر قريبًا:

```text
Flutter = UI cache فقط
Rust Engine = Source of Truth للإعدادات المهمة
```

أو نبقي Flutter هو المصدر مؤقتًا لكن نزامنه مع Rust عند كل Save.

**القرار المقترح:** Rust يكون Source of Truth بعد Step 10، وFlutter يحتفظ بنسخة UI فقط.

---

## 3.2 لا يوجد Engine Client في Flutter
رغم وجود `dio`، لا يوجد service مثل:

```text
lib/app/data/services/engine_client_service.dart
```

وهذا هو الرابط الناقص بين الواجهة والـ Engine.

---

## 3.3 Chat غير موجود فعليًا
رغم أن Runtime endpoint موجود، لا توجد شاشة Chat تستخدمه.

---

## 3.4 Memory موجودة في Rust لكن غير مرئية في Flutter
Data Center ما زال Placeholder.

---

## 3.5 Workspace Editor ليس محررًا فعليًا بعد
حاليًا هو Preview ممتاز كبداية، لكن لا يوجد Edit/Save.

---

# 4. الخطوات المقترحة بعد المراجعة

## Step 11 — Flutter Engine Client + Engine Status Sync
**الأولوية:** P0

### الهدف
ربط Flutter بالـ Rust Engine بدون تشغيل موديل فعلي.

### المطلوب
- إضافة Service:
  - `lib/app/data/services/engine_client_service.dart`
- يستخدم `dio` لقراءة:
  - `GET /health`
  - `GET /status`
  - `GET /settings`
  - `GET /runtime/status`
- إضافة حالة Engine داخل TopBar أو Settings:
  - Engine Online
  - Engine Offline
  - Local Model Enabled
  - Runtime Stage
- عدم تشغيل GGUF.

### الناتج المتوقع
Flutter يعرف هل Rust Engine شغال ولا لأ.

---

## Step 12 — Sync Local Model Settings to Rust
**الأولوية:** P0

### الهدف
عند حفظ إعدادات الموديل في Flutter، يتم إرسالها إلى Rust Engine.

### المطلوب
- عند `saveLocalModelSettings()` يتم POST إلى:
  - `/runtime/profile`
- عند `saveSystemPrompt()` يتم POST إلى:
  - `/runtime/system-prompt`
- معالجة حالة فشل الاتصال بدون كراش.
- عرض رسالة واضحة:
  - تم الحفظ محليًا فقط.
  - تم الحفظ محليًا وفي Rust.

### الناتج المتوقع
Flutter Settings وRust Config لا يفضلوا منفصلين.

---

## Step 13 — Real Chat Page Skeleton
**الأولوية:** P0

### الهدف
استبدال ChatPage placeholder بشاشة شات حقيقية مبدئية.

### المطلوب
- إزالة TODO من `ChatPageController`.
- UI بسيط:
  - قائمة رسائل.
  - Text input.
  - Send button.
- عند الإرسال:
  - يرسل prompt إلى `/runtime/chat`.
  - يعرض response lifecycle message مؤقتًا.
- لا يوجد GGUF فعلي بعد.

### الناتج المتوقع
الشات يبدأ يستخدم Runtime endpoint فعليًا.

---

## Step 14 — Auto-save Chat to Rust Memory
**الأولوية:** P0

### الهدف
أي رسالة شات تتحفظ في Memory SQLite.

### المطلوب
- إنشاء conversation تلقائيًا عند أول رسالة.
- حفظ user message في:
  - `POST /memory/messages`
- حفظ assistant/runtime response في:
  - `POST /memory/messages`
- ربط conversation بـ:
  - workspace path إن وجد.
  - active model profile.
  - system prompt preview.

### الناتج المتوقع
Memory System تبدأ تبقى مستخدمة فعليًا، مش endpoints فقط.

---

## Step 15 — Data Center / Memory UI
**الأولوية:** P1

### الهدف
تشغيل زر Data Center بدل Coming Soon.

### المطلوب
- شاشة Memory/Data Center.
- تعرض:
  - conversations count.
  - messages count.
  - memory items.
  - experts.
  - workspace sessions.
- قراءة البيانات من Rust endpoints.

---

## Step 16 — Workspace Sessions Sync
**الأولوية:** P1

### الهدف
كل مرة يفتح Workspace أو File، تتسجل جلسة في Rust Memory.

### المطلوب
- عند فتح Workspace:
  - `POST /memory/workspace-sessions`
- عند فتح File:
  - تحديث/إضافة session metadata.
- حفظ آخر Active Workspace لاحقًا من Rust أو sync واضح.

---

## Step 17 — Workspace Context Menu
**الأولوية:** P1

### الهدف
استخدام `super_context_menu` في شجرة الملفات.

### المطلوب
- Right click على file/folder.
- Actions مبدئية:
  - Open
  - Reveal path
  - Copy path
  - Refresh
- تأجيل Create/Rename/Delete لو عايزين أمان أعلى.

---

## Step 18 — Real Terminal
**الأولوية:** P1

### الهدف
تحويل Terminal placeholder إلى طرفية حقيقية.

### المطلوب
- استخدام `xterm` + `flutter_pty`.
- التشغيل داخل active workspace path.
- زر Stop/Restart terminal.
- حماية من تشغيل أوامر تلقائية بدون طلب واضح.

---

## Step 19 — Real Code Editor
**الأولوية:** P1

### الهدف
تحويل Preview إلى Editor حقيقي.

### المطلوب
- استخدام `flutter_code_editor`.
- Edit / Save.
- Unsaved indicator.
- حماية الملفات الكبيرة/binary.
- حفظ logs عند الحفظ.

---

## Step 20 — Runtime GGUF Adapter Planning
**الأولوية:** P2

### الهدف
تخطيط تشغيل GGUF الحقيقي قبل التنفيذ.

### المطلوب قبل الكود
- تحديد هل adapter سيكون:
  - `llama.cpp` process manager.
  - أو Rust binding لاحقًا.
- تحديد path لـ llama binary.
- تحديد process lifecycle.
- تحديد streaming أو non-streaming.
- تحديد logs/errors.

### ملاحظة
لا ننفذ تشغيل موديل حقيقي قبل تثبيت:
- Engine Client.
- Chat UI.
- Memory Save.
- Review security/process policy.

---

# 5. Cleanup مطلوب قبل التوسع الكبير

## C1 — README Consistency Review
**الأولوية:** P1 — يحتاج إذن صريح لتعديل README.

يوجد في `README.md` جزء ترتيب لاحق لا يعكس كل الخطوات التي تمت بعد Step 10 بدقة. لا يتم تعديله إلا بطلب صريح.

## C2 — Zip / Project package completeness
**الأولوية:** P1

النسخة المرفوعة للمراجعة لا تحتوي على `pubspec.yaml`. في المراجعات القادمة، الأفضل رفع مشروع كامل أو تأكيد أن zip يحتوي فقط على الملفات المعدلة.

## C3 — Remove dead placeholders when their pages become real
**الأولوية:** P2

- `localModelComingSoon`
- `dataCenterComingSoon`
- `ChatPageView is working`
- top bar search/commands empty callbacks

## C4 — Add endpoint test scripts
**الأولوية:** P2

إضافة سكريبتات بسيطة لاحقًا:

```text
scripts/test_engine_health.sh
scripts/test_runtime_profile.sh
scripts/test_memory_endpoints.sh
```

---

# 6. القرار المقترح للخطوة القادمة

الخطوة المنطقية بعد هذه المراجعة:

```text
Step 11 — Flutter Engine Client + Engine Status Sync
```

ثم:

```text
Step 12 — Sync Settings/System Prompt to Rust
Step 13 — Real Chat Page Skeleton
Step 14 — Auto-save Chat to Rust Memory
```

بهذا الترتيب نبدأ نربط الأجزاء الموجودة بدل إضافة واجهات جديدة غير مربوطة.
