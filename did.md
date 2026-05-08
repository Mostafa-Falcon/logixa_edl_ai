# did.md — Logixa EDL AI Execution Log

## Step 2 / Step 3 — Settings Page + Local Model Settings

### الهدف
تنفيذ الخطوة التالية المذكورة في `README.md` بدون تعديل ملف `README.md`:
- إنشاء صفحة إعدادات حقيقية `/settings`.
- تنفيذ قسم إعدادات الموديل المحلي فقط في هذه المرحلة.
- جعل اختيار الموديل المحلي ديناميكي من الواجهة بدل أي مسار ثابت في الكود.
- حفظ إعدادات الموديل مؤقتًا باستخدام `GetStorage` لحد دخول Rust Engine وSQLite.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الخطوة متوافقة مع الخطة: Step 2 وStep 3 في README.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- إضافة موديل بيانات للموديل المحلي:
  - `lib/app/data/models/model_profile_model.dart`
- إضافة خدمة مركزية لإعدادات التطبيق بدل نشر `GetStorage` في كل Controller:
  - `lib/app/data/services/app_settings_service.dart`
- تسجيل `AppSettingsService` في `main.dart` بعد `GetStorage.init()`.
- إضافة Module جديد للإعدادات:
  - `lib/app/modules/settings/bindings/settings_binding.dart`
  - `lib/app/modules/settings/controllers/settings_controller.dart`
  - `lib/app/modules/settings/views/settings_view.dart`
  - `lib/app/modules/settings/views/sections/local_model_settings_section.dart`
- إضافة Route جديد:
  - `/settings`
- ربط زر الإعدادات في TopBar بصفحة Settings.
- ربط زر الإعدادات في Workspace Activity Bar بصفحة Settings.
- ربط Quick Action الخاصة بالموديل المحلي في Home بصفحة Settings.
- ربط عنصر الإعدادات في Home Sidebar بصفحة Settings.
- جعل `TopBarController` يقرأ حالة تفعيل الموديل المحلي من `AppSettingsService` بدل State محلي منفصل.
- إضافة حفظ الإعدادات التالية:
  - تفعيل/إيقاف الموديل المحلي.
  - اختيار ملف موديل `.gguf` عبر `file_picker`.
  - اسم الموديل.
  - مسار الموديل.
  - context size.
  - threads.
  - batch size.
  - max tokens.
  - temperature.
  - top_p.
  - keep model loaded.
  - unload after response.
  - auto start on message.
  - allow background model.

### الملفات التي تم تعديلها
- `lib/main.dart`
- `lib/app/constants/app_strings.dart`
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `lib/app/modules/home/bindings/home_binding.dart`
- `lib/app/modules/home/controllers/home_controller.dart`
- `lib/app/modules/work_space/bindings/work_space_binding.dart`
- `lib/app/modules/work_space/views/sections/workspace_activity_bar.dart`
- `lib/app/widgets/app_core/controller/top_bar_controller.dart`
- `lib/app/widgets/app_core/view/sections/top_bar_actions_section.dart`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/data/models/model_profile_model.dart`
- `lib/app/data/services/app_settings_service.dart`
- `lib/app/modules/settings/bindings/settings_binding.dart`
- `lib/app/modules/settings/controllers/settings_controller.dart`
- `lib/app/modules/settings/views/settings_view.dart`
- `lib/app/modules/settings/views/sections/local_model_settings_section.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تشغيل موديل محلي فعليًا.
- لم يتم إنشاء Rust Engine في هذه الخطوة.
- لم يتم استخدام Drift أو توليد Tables.
- لم يتم تعديل README.md.
- لم يتم إضافة Model Profiles متعددة؛ تم تنفيذ Single Active Model Profile فقط كما هو مذكور في README لتجنب التوسع المبكر.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

### الخطوة القادمة حسب README.md
Step 4 — Model Profile System، لكن التنفيذ القادم يجب أن يظل صغيرًا:
- إما تحسين `ModelProfileModel` ليدعم قائمة Profiles متعددة.
- أو تأجيل تعدد Profiles مؤقتًا والانتقال إلى Step 5 لو قرر مصطفى ذلك.

### ملاحظة مهمة
أي خطوة قادمة يجب أن تبدأ بمراجعة `README.md` و`did.md` أولًا، ثم تنفيذ المطلوب فقط، مع تحديث `did.md` بعد التنفيذ.

---

## Step 4 — Model Profile System / Initial Multi-Profile Support

### الهدف
تنفيذ الخطوة التالية من `README.md` بشكل صغير ومنظم:
- تحويل إعدادات الموديل المحلي من بروفايل واحد فقط إلى نظام بروفايلات مبدئي.
- السماح بإضافة أكثر من بروفايل موديل محلي.
- السماح بتعيين بروفايل نشط وتعديله من نفس صفحة الإعدادات.
- الحفاظ على التصميم الموحد وإخراج أي Widget متكرر إلى reusable widgets.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي قبل التنفيذ.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الخطوة متوافقة مع Step 4 المذكورة في `README.md`.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- تحديث `AppSettingsService` لدعم قائمة بروفايلات موديلات محلية بدل حفظ بروفايل واحد فقط.
- الحفاظ على التوافق مع التخزين القديم `active_model_profile` بحيث لا تضيع الإعدادات السابقة.
- إضافة عمليات:
  - إضافة بروفايل موديل جديد.
  - تعيين بروفايل كنشط.
  - حذف بروفايل مع منع حذف آخر بروفايل.
  - حفظ البروفايل النشط وتحديث القائمة.
- تحديث `SettingsController` لإدارة البروفايلات:
  - إنشاء بروفايل جديد باسم مبدئي.
  - اختيار بروفايل من القائمة وتعبئة حقول الفورم الخاصة به.
  - حذف بروفايل.
  - حفظ تعديلات البروفايل النشط.
- تقسيم صفحة إعدادات الموديل المحلي إلى سكاشن صغيرة بدل ملف كبير مزدحم:
  - `LocalModelRuntimePolicySection`
  - `ModelProfilesSection`
  - `ActiveModelProfileFormSection`
  - `SettingsHeaderSection`
- إضافة reusable widgets جديدة بدل تكرار عناصر الإعدادات داخل السكشن:
  - `ReusableSettingsSwitchTile`
  - `ReusableSettingsTextField`
  - `ReusableModelProfileCard`
- تحديث `LocalModelSettingsSection` ليكون ملف تجميعي خفيف فقط.
- إضافة نصوص جديدة داخل `AppStrings` للبروفايلات ورسائل الحفظ والحذف.
- إضافة animation خفيف في كروت البروفايلات وSwitch tiles بدون تغيير اتجاه التصميم.

### الملفات التي تم تعديلها
- `lib/app/data/services/app_settings_service.dart`
- `lib/app/modules/settings/controllers/settings_controller.dart`
- `lib/app/modules/settings/views/sections/local_model_settings_section.dart`
- `lib/app/constants/app_strings.dart`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/modules/settings/views/sections/local_model_runtime_policy_section.dart`
- `lib/app/modules/settings/views/sections/model_profiles_section.dart`
- `lib/app/modules/settings/views/sections/active_model_profile_form_section.dart`
- `lib/app/modules/settings/views/sections/settings_header_section.dart`
- `lib/app/widgets/reusable_widgets/reusable_settings_switch_tile.dart`
- `lib/app/widgets/reusable_widgets/reusable_settings_text_field.dart`
- `lib/app/widgets/reusable_widgets/reusable_model_profile_card.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تشغيل الموديل المحلي فعليًا.
- لم يتم إنشاء Rust Engine في هذه الخطوة.
- لم يتم استخدام Drift أو SQLite.
- لم يتم تنفيذ شاشة منفصلة لإدارة كل بروفايل؛ الإدارة الحالية مبدئية داخل Settings.
- لم يتم تعديل `README.md`.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

### الخطوة القادمة حسب README.md
Step 5 — Workspace Tree Polish:
- تحسين شجرة الملفات.
- تثبيت ignore folders.
- فتح الملفات في editor بشكل أنضف.
- تجهيز right click لاحقًا باستخدام `super_context_menu`.

### ملاحظة مهمة
قبل تنفيذ Step 5 يجب مراجعة `README.md` و`did.md` مرة أخرى، ولو ظهر تعارض أو توسع زائد يجب الوقوف ومناقشة القرار قبل التنفيذ.

## Fix Step — Settings Model Profiles Obx Crash

### الهدف
إصلاح كراش GetX الظاهر داخل صفحة Settings في قسم بروفايلات الموديلات بدون تنفيذ Feature جديدة وبدون تعديل `README.md`.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الإصلاح متوافق مع Step 4 الحالي لأن المشكلة داخل `Model Profile System`.
- لم يتم تعديل `README.md`.

### سبب المشكلة
كان `Obx` في `ModelProfilesSection` يلف `LayoutBuilder`، لكن قراءة الـ observable كانت تتم داخل `LayoutBuilder.builder` وداخل loop العرض. هذا جعل GetX لا يرى قراءة observable مباشرة داخل نطاق `Obx`، فظهر خطأ improper use of GetX.

### ما تم تنفيذه
- تعديل `ModelProfilesSection` بحيث يقرأ القيم المتغيرة مباشرة داخل جسم `Obx` قبل `LayoutBuilder`:
  - `settingsService.modelProfiles.toList(growable: false)`
  - `settingsService.activeModelProfile.value.id`
- استخدام النسخ المقروءة داخل `LayoutBuilder` بدل قراءة الـ Rx مباشرة داخل builder.
- الحفاظ على نفس التصميم ونفس السلوك بدون إضافة أي واجهات جديدة.

### الملفات التي تم تعديلها
- `lib/app/modules/settings/views/sections/model_profiles_section.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تنفيذ Step 5.
- لم يتم تنظيف warnings الخاصة بـ `withOpacity` لأنها ليست سبب الكراش الحالي وتحتاج خطوة تنظيف مستقلة.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

### الخطوة القادمة حسب README.md
بعد تأكيد اختفاء كراش Settings، نرجع للخطة:
Step 5 — Workspace Tree Polish.


---

## Fix Step — topKController LateInitializationError + Sampling Defaults

### الهدف
إصلاح كراش صفحة الإعدادات بعد إضافة `top_k` بدون تنفيذ Feature جديدة وبدون تعديل `README.md`.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الإصلاح داخل نطاق Step 4 / Model Profile System لأنه متعلق بإعدادات بروفايل الموديل المحلي.
- لم يتم تعديل `README.md`.

### سبب المشكلة
ظهر Runtime error عند فتح صفحة Settings:
- `LateInitializationError: Field 'topKController' has not been initialized.`

السبب أن `topKController` اتضاف كـ `late final`، ومع تغييرات hot reload / lifecycle كان ممكن الواجهة تبني الحقل قبل تهيئة الـ controller بشكل آمن.

### ما تم تنفيذه
- تحويل كل `TextEditingController` داخل `SettingsController` من `late final` إلى `final` مهيّأ مباشرة.
- جعل `onInit()` يستدعي `_syncControllersFromProfile(...)` فقط لتعبئة القيم بدل إنشاء controllers داخله.
- الحفاظ على `dispose()` لكل controllers كما هو.
- ضبط defaults الخاصة بإعدادات sampling في `ModelProfileModel.defaultLocal()`:
  - `temperature = 1.0`
  - `top_p = 0.95`
  - `top_k = 64`
- تحديث hints الخاصة بالحقول في `ActiveModelProfileFormSection` لتطابق القيم الجديدة.

### الملفات التي تم تعديلها
- `lib/app/modules/settings/controllers/settings_controller.dart`
- `lib/app/data/models/model_profile_model.dart`
- `lib/app/modules/settings/views/sections/active_model_profile_form_section.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تنفيذ Step 5.
- لم يتم تغيير نظام التخزين أو Rust Engine.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

### ملاحظة تشغيل مهمة
بعد تغيير حقول داخل `ModelProfileModel` أو `SettingsController` لا نعتمد على hot reload. يجب عمل hot restart، ولو استمر الخطأ يتم إيقاف التطبيق وتشغيله من جديد:

```bash
q
flutter run -d linux
```

### الخطوة القادمة حسب README.md
بعد تأكيد أن Settings تفتح بدون أي Runtime error:
Step 5 — Workspace Tree Polish.

---

## Step 5 — Workspace Tree Polish

### الهدف
تنفيذ الخطوة التالية من `README.md` بعد استقرار Settings وModel Profiles:
- تحسين شجرة ملفات Workspace بشكل أقرب لأسلوب EDL / VS Code.
- تثبيت ignore folders عشان المشاريع الكبيرة ما تعملش Freeze.
- تحسين فتح الملفات وعرض مسارها في Editor بشكل أنضف.
- الحفاظ على التصميم الموحد وClean Code بدون تعديل `README.md`.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي قبل التنفيذ.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الخطوة متوافقة مع Step 5 المذكورة في `README.md`.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- تحسين `WorkSpaceController`:
  - إضافة `expandAllDirectories()` لتوسيع كل المجلدات الظاهرة.
  - إضافة `collapseAllDirectories()` لطي الشجرة.
  - إضافة `openedFileSubtitle` لعرض المسار النسبي وحجم الملف بدل المسار المطلق الطويل فقط.
  - إضافة `openedFileSizeLabel` لتخزين حجم الملف المفتوح بصيغة سهلة القراءة.
  - رفع حدود قراءة الشجرة بشكل آمن إلى عمق 5 ومستوى 900 عنصر مع استمرار القراءة داخل Isolate.
  - توسيع قائمة ignored folders لتشمل caches وأدوات شائعة مثل `.fvm`, `.mypy_cache`, `.pytest_cache`, `.ruff_cache`, `.turbo`, `.parcel-cache`, `vendor`.
- تحسين `WorkspaceFileExplorer`:
  - إضافة أزرار أعلى الشجرة: Refresh / Expand All / Collapse All.
  - تحسين Root Header لعرض اسم المشروع ومساره بشكل أوضح.
  - إضافة Footer يعرض عدد العناصر المقروءة وينبه إذا الشجرة وصلت لحد الأداء.
  - الحفاظ على نفس الألوان والتصميم الموحد.
- إخراج عنصر الشجرة المتكرر إلى reusable widget:
  - `ReusableWorkspaceTreeTile`
- تحسين أيقونات الشجرة لبعض المجلدات الشائعة:
  - `models`, `services`, `constants`, `theme`, `assets`
- تحسين Header محرر الملفات ليعرض المسار النسبي + حجم الملف.

### الملفات التي تم تعديلها
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `lib/app/modules/work_space/views/sections/workspace_file_explorer.dart`
- `lib/app/modules/work_space/views/sections/workspace_editor_area.dart`
- `lib/app/constants/app_strings.dart`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/widgets/reusable_widgets/reusable_workspace_tree_tile.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تنفيذ Editor Tabs في هذه الخطوة؛ لأنها Step 6 حسب `README.md`.
- لم يتم تنفيذ right-click context menu حتى لا يتوسع Step 5 أكثر من المطلوب.
- لم يتم استخدام `super_context_menu` فعليًا بعد؛ سيبقى مناسبًا لخطوة لاحقة خاصة بقوائم الملفات.
- لم يتم تعديل `README.md`.
- لم يتم إنشاء Rust Engine أو تشغيل موديل محلي.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

### الخطوة القادمة حسب README.md
Step 6 — Editor Tabs:
- تحويل فتح الملفات من Preview واحد إلى Tabs.
- استخدام `tabbed_view` و`flutter_code_editor` بشكل تدريجي.
- دعم إغلاق التبويب وتحديد الملف النشط.

### ملاحظة مهمة
لو ظهر أي Freeze أو كراش في Workspace بعد الخطوة دي، يتم إيقاف تنفيذ Step 6 مؤقتًا وإصلاح Workspace Tree أولًا قبل إضافة Tabs.

---

## Step 6 — Editor Tabs

### الهدف
تنفيذ الخطوة التالية من `README.md` بدون تعديل `README.md`:
- تحويل فتح الملفات من preview واحد إلى نظام Tabs مبدئي داخل Workspace.
- دعم فتح أكثر من ملف في نفس الوقت.
- دعم اختيار التبويب النشط وإغلاق التبويبات.
- الحفاظ على التصميم الموحد وإخراج عنصر التاب المتكرر إلى reusable widget.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الخطوة متوافقة مع Step 6 المذكورة في `README.md`.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- إضافة موديل خفيف لتمثيل الملف المفتوح داخل التابات:
  - `OpenedFileModel`
- تحديث `WorkSpaceController` لدعم:
  - قائمة ملفات مفتوحة `openedFiles`.
  - فتح ملف في تبويب جديد إذا لم يكن مفتوحًا.
  - التركيز على التبويب الموجود بدل تكراره إذا كان الملف مفتوحًا بالفعل.
  - تغيير التبويب النشط.
  - إغلاق تبويب وتحديد تبويب بديل تلقائيًا.
  - مسح التابات عند تحديث/تغيير مساحة العمل.
- تحديث `WorkspaceEditorArea` لإضافة:
  - شريط Tabs أعلى مساحة الكود.
  - Header يعرض الملف النشط والمسار النسبي والحجم.
  - بقاء preview النصي الحالي كما هو بدون تحويله لمحرر كامل في هذه الخطوة.
- إضافة reusable widget لعنصر التاب:
  - `ReusableEditorTab`
- إضافة نص جديد لحالة عدم وجود ملفات مفتوحة.

### الملفات التي تم تعديلها
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `lib/app/modules/work_space/views/sections/workspace_editor_area.dart`
- `lib/app/constants/app_strings.dart`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/data/models/opened_file_model.dart`
- `lib/app/widgets/reusable_widgets/reusable_editor_tab.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تنفيذ تعديل أو حفظ الملفات.
- لم يتم تنفيذ مؤشر unsaved changes.
- لم يتم إدخال `flutter_code_editor` كمحرر كامل حتى لا تتوسع الخطوة.
- لم يتم تنفيذ Terminal أو Bottom Panel.
- لم يتم تعديل `README.md`.
- لم يتم إنشاء Rust Engine أو تشغيل موديل محلي.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

### الخطوة القادمة حسب README.md
Step 7 — Bottom Panel:
- إضافة Panel سفلي مبدئي يحتوي على Terminal / Logs / Problems / Output.
- استخدام `xterm` و`flutter_pty` لاحقًا بشكل تدريجي.
- عدم تشغيل Rust Engine في هذه الخطوة إلا لو تم الاتفاق صراحة.

### ملاحظة مهمة
لو ظهر أي كراش في tabs أو file opening، يتم إيقاف Step 7 مؤقتًا وإصلاح نظام التابات أولًا.

---

## Step 7 — Bottom Panel

### الهدف
تنفيذ الخطوة التالية من `README.md` بدون تعديل `README.md`:
- إضافة Panel سفلي مبدئي داخل Workspace.
- تجهيز Tabs للـ Terminal / Logs / Problems / Output.
- الحفاظ على التصميم الموحد وأسلوب Clean Code.
- عدم تشغيل Terminal حقيقي أو Rust Engine في هذه الخطوة.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الخطوة متوافقة مع Step 7 المذكورة في `README.md`.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- إضافة Bottom Panel أسفل مساحة الكود داخل `WorkSpaceView`.
- إضافة Tabs داخل اللوحة السفلية:
  - Terminal
  - Logs
  - Problems
  - Output
- إضافة حالة فتح/إخفاء اللوحة السفلية مع animation خفيف.
- إضافة Logs مبدئية داخل `WorkSpaceController` تسجل:
  - تحميل مساحة العمل.
  - قراءة شجرة الملفات.
  - فتح ملف.
  - إغلاق تبويب.
  - أخطاء قراءة/فتح الملفات.
- إضافة زر مسح اللوجات داخل Logs tab.
- إضافة Problems tab يعرض رسالة الخطأ الحالية إن وجدت، أو حالة عدم وجود مشاكل.
- إضافة Output tab يعرض ملخص مساحة العمل:
  - اسم workspace.
  - المسار.
  - عدد العناصر المقروءة.
  - عدد التابات المفتوحة.
  - الملف النشط.
- إضافة Terminal placeholder فقط، بدون تشغيل shell حقيقي، لأن استخدام `xterm` و`flutter_pty` سيتم في خطوة مستقلة لاحقًا.
- إخراج عنصر Bottom Panel tab إلى reusable widget:
  - `ReusableWorkspaceBottomTab`

### الملفات التي تم تعديلها
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `lib/app/modules/work_space/views/work_space_view.dart`
- `lib/app/constants/app_sizes.dart`
- `lib/app/constants/app_strings.dart`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/modules/work_space/views/sections/workspace_bottom_panel.dart`
- `lib/app/widgets/reusable_widgets/reusable_workspace_bottom_tab.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تشغيل Terminal حقيقي.
- لم يتم استخدام `xterm` و`flutter_pty` فعليًا بعد.
- لم يتم تشغيل Rust Engine.
- لم يتم تنفيذ Problems analyzer حقيقي.
- لم يتم تنفيذ Logs قادمة من backend؛ اللوجات الحالية UI/workspace logs فقط.
- لم يتم تعديل `README.md`.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

### الخطوة القادمة حسب README.md
Step 8 — Rust Engine Skeleton:
- إنشاء/تثبيت هيكل Rust Engine خفيف.
- health endpoint.
- status endpoint.
- settings endpoint.
- ربط Flutter لاحقًا بـ `dio` و`web_socket_channel` عند الحاجة.

### ملاحظة مهمة
قبل تنفيذ Step 8 يجب مراجعة `README.md` و`did.md` مرة أخرى، ولو كان Rust Engine الحالي في المشروع موجودًا بالفعل يجب عدم إعادة إنشائه من الصفر؛ نراجع الموجود ونكمل عليه فقط.

---

## Step 8 — Rust Engine Skeleton

### الهدف
تنفيذ الخطوة التالية من `README.md` بدون تعديل `README.md`:
- إنشاء هيكل Rust Engine محلي خفيف داخل `logixa_engine/`.
- إضافة endpoints أساسية فقط: `health`, `status`, `settings`.
- تجهيز engine مستقل لا يشغل موديل محلي ولا يلمس Flutter UI في هذه الخطوة.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الخطوة متوافقة مع Step 8 المذكورة في `README.md`.
- لم يتم تعديل `README.md`.
- تم التأكد من أن بعض الأجزاء السابقة قد تكون جزئية/Placeholder لحين مراجعة شاملة بعد Step 10، حسب الاتفاق.

### ما تم تنفيذه
- إنشاء مشروع Rust داخل:
  - `logixa_engine/`
- إضافة `Cargo.toml` بالاعتماديات الأساسية فقط:
  - `tokio`
  - `axum`
  - `tower-http`
  - `serde`
  - `serde_json`
  - `anyhow`
  - `thiserror`
  - `tracing`
  - `tracing-subscriber`
- إضافة server محلي خفيف يستمع افتراضيًا على:
  - `127.0.0.1:8787`
- إضافة endpoint:
  - `GET /health`
  - يرجع حالة جاهزية engine ونسخة الخدمة ومسار ملف الإعدادات.
- إضافة endpoint:
  - `GET /status`
  - يرجع حالة engine والسياسات الحالية مع `model_loaded = false` لأن Step 8 لا يشغل موديلات.
- إضافة endpoint:
  - `GET /settings`
  - يرجع إعدادات engine الحالية.
- إضافة config system بسيط:
  - يقرأ من `LOGIXA_ENGINE_CONFIG` لو متغير البيئة موجود.
  - وإلا يستخدم `logixa_engine_config.json` داخل مكان تشغيل engine.
  - ينشئ ملف config افتراضي إذا لم يكن موجودًا.
- إضافة ملف مثال للإعدادات:
  - `logixa_engine/logixa_engine_config.example.json`
- إضافة `.gitignore` داخل `logixa_engine/` لمنع رفع `target/` وملف config المحلي.

### الملفات التي تم إضافتها
- `logixa_engine/Cargo.toml`
- `logixa_engine/.gitignore`
- `logixa_engine/logixa_engine_config.example.json`
- `logixa_engine/src/main.rs`
- `logixa_engine/src/config.rs`
- `logixa_engine/src/routes.rs`
- `logixa_engine/src/state.rs`

### الملفات التي تم تعديلها
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم ربط Flutter بالـ Rust Engine في هذه الخطوة.
- لم يتم تشغيل موديل GGUF.
- لم يتم إضافة Runtime Model Manager.
- لم يتم إضافة SQLite أو Memory System.
- لم يتم تشغيل Terminal حقيقي.
- لم يتم استخدام `dio` أو `web_socket_channel` بعد.

### أوامر الفحص المطلوبة
```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

وفي terminal آخر:

```bash
curl http://127.0.0.1:8787/health
curl http://127.0.0.1:8787/status
curl http://127.0.0.1:8787/settings
```

وللتأكد أن Flutter ما زال سليمًا:

```bash
flutter pub get
flutter analyze
flutter run -d linux
```

### ملاحظة تنفيذ
لم يتم تشغيل `cargo check` داخل بيئة التنفيذ هنا لأن Cargo/Rust toolchain غير متاحين في البيئة الحالية. يجب تشغيل أوامر Cargo على جهازك المحلي.

### الخطوة القادمة حسب README.md
Step 9 — Runtime Model Manager:
- تجهيز مدير تشغيل الموديل المحلي في Rust.
- قراءة active model profile لاحقًا.
- تشغيل الموديل عند إرسال الرسالة فقط.
- إيقاف/تفريغ الموديل بعد الرد حسب السياسة.
- عدم التوسع قبل التأكد أن Step 8 يعمل بـ `cargo check` و endpoints ترجع JSON سليم.

### ملاحظة مهمة
لو فشل `cargo check` أو ظهرت مشكلة في تشغيل السيرفر، يتم إيقاف Step 9 مؤقتًا وإصلاح Rust Engine Skeleton أولًا.

---

## Step 9 — Runtime Model Manager Preparation

### الهدف
تنفيذ الخطوة التالية من `README.md` بدون تعديل `README.md`:
- تجهيز مدير تشغيل الموديل المحلي داخل Rust Engine.
- تثبيت عقد Runtime lifecycle قبل ربط تشغيل GGUF الحقيقي.
- دعم استقبال بروفايل موديل نشط وسياسات التشغيل.
- التأكد أن الموديل لا يظل محمّلًا افتراضيًا بعد الطلب.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- Step 8 تم التحقق منه محليًا عند مصطفى: Flutter analyze نظيف، وRust `cargo check` نجح، وendpoints الأساسية `/health`, `/status`, `/settings` رجعت JSON صحيح.
- الخطوة متوافقة مع Step 9 المذكورة في `README.md`.
- لم يتم تعديل `README.md`.
- حسب الاتفاق، بعض أجزاء UI السابقة قد تظل Placeholder لحين مراجعة شاملة بعد Step 10.

### ما تم تنفيذه
- إضافة موديل Rust لبروفايل الموديل المحلي:
  - `ModelProfileConfig`
- إضافة دعم `active_model_profile` داخل `EngineConfig` بجانب `active_model_profile_id`.
- إضافة normalization لقيم بروفايل الموديل داخل Rust:
  - name/id fallback.
  - context size fallback.
  - threads fallback.
  - batch size fallback.
  - max tokens fallback.
  - temperature fallback.
  - top_p fallback.
  - top_k fallback.
- إضافة Runtime Manager خفيف داخل Rust:
  - يتتبع حالة runtime.
  - يسجل عدد الطلبات.
  - يسجل آخر حدث وآخر خطأ.
  - يدعم unload يدوي.
- إضافة endpoint جديد:
  - `GET /runtime/status`
  - يرجع حالة Runtime الحالية فقط.
- إضافة endpoint جديد:
  - `POST /runtime/profile`
  - يستقبل بروفايل موديل وسياسات تشغيل اختيارية.
  - يحفظ البروفايل داخل config.
  - يحدث `active_model_profile_id` تلقائيًا من `profile.id`.
- إضافة endpoint جديد:
  - `POST /runtime/chat`
  - يطبق policy checks فقط في هذه الخطوة.
  - يرفض التشغيل لو `local_model_enabled = false`.
  - يرفض التشغيل لو `auto_start_on_message = false`.
  - يرفض التشغيل لو prompt فاضي.
  - يرفض التشغيل لو لا يوجد active model profile.
  - يرفض التشغيل لو active profile ليس به `model_path`.
  - لو الشروط صحيحة، ينفذ lifecycle mock آمن: preparing ثم completed ثم unload حسب السياسة.
- إضافة endpoint جديد:
  - `POST /runtime/unload`
  - يفرغ حالة runtime ويرجعها إلى idle.
- تحديث `/status` ليعرض snapshot من Runtime Manager بدل قيمة ثابتة لـ `model_loaded`.
- تحديث `logixa_engine_config.example.json` لإضافة `active_model_profile`.

### الملفات التي تم إضافتها
- `logixa_engine/src/model_profile.rs`
- `logixa_engine/src/runtime.rs`

### الملفات التي تم تعديلها
- `logixa_engine/src/main.rs`
- `logixa_engine/src/config.rs`
- `logixa_engine/src/state.rs`
- `logixa_engine/src/routes.rs`
- `logixa_engine/logixa_engine_config.example.json`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تشغيل GGUF فعليًا.
- لم يتم ربط `llama.cpp` أو أي runtime adapter حقيقي.
- لم يتم ربط Flutter بهذه endpoints بعد.
- لم يتم إضافة SQLite أو Memory System.
- لم يتم تنفيذ Chat UI.
- لم يتم إبقاء الموديل محمّلًا افتراضيًا؛ السياسة الافتراضية ما زالت `unload_after_response = true` و `keep_model_loaded = false`.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

وفي terminal آخر:

```bash
curl http://127.0.0.1:8787/runtime/status
```

اختبار حفظ بروفايل Runtime:

```bash
curl -X POST http://127.0.0.1:8787/runtime/profile \
  -H "Content-Type: application/json" \
  -d '{
    "local_model_enabled": true,
    "model_profile": {
      "id": "gemma_fast_local",
      "name": "Gemma Fast Local",
      "model_path": "/home/logixa/models/gemma.gguf",
      "context_size": 2048,
      "threads": 6,
      "batch_size": 256,
      "max_tokens": 512,
      "temperature": 1.0,
      "top_p": 0.95,
      "top_k": 64
    }
  }'
```

اختبار lifecycle مبدئي بدون تشغيل GGUF فعلي:

```bash
curl -X POST http://127.0.0.1:8787/runtime/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt":"اختبار تشغيل دورة runtime فقط"}'
```

اختبار unload:

```bash
curl -X POST http://127.0.0.1:8787/runtime/unload
```

### الخطوة القادمة حسب README.md
Step 10 — Memory System:
- تجهيز ذاكرة محلية أساسية لاحقًا باستخدام Rust + SQLite.
- تخزين conversations/messages/memory_items/selected_model_profile/experts/workspace_sessions.
- Firebase يظل مؤجلًا كـ backup/sync وليس core memory.

### ملاحظة مهمة
بعد Step 10 يجب تنفيذ مراجعة شاملة كما اتفقنا:
- ما هو فعال 100%.
- ما هو UI فقط.
- ما هو Placeholder.
- ما يحتاج ربط.
- ما يحتاج تنظيف أو إصلاح.

## Step 9.1 — Dynamic System Prompt + Runtime Warning Cleanup

### الهدف
تنفيذ خطوة صغيرة قبل Step 10 بناءً على قرار مصطفى:
- جعل `system_prompt` ديناميكيًا من Flutter Settings بدل تركه ثابتًا أو غير مستخدم.
- تنظيف تحذير Rust الذي ظهر في Step 9: `field system_prompt is never read`.
- الحفاظ على Step 10 مؤجلًا لحين اكتمال هذه الخطوة.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الخطوة لا تتعارض مع README لأنها تدعم سياسة أن الرسالة تُرسل مع `system prompt` قبل تشغيل الموديل المحلي.
- لم يتم تعديل `README.md`.
- تم اعتبار رسائل إغلاق Flutter Linux وكتابة `cd logixa_engine` من داخل نفس المجلد غير blockers؛ لم يتم توسيع نطاق الخطوة لمعالجتها الآن.

### ما تم تنفيذه في Flutter
- إضافة `systemPrompt` داخل `AppSettingsService` وتخزينه مؤقتًا في `GetStorage` تحت مفتاح:
  - `active_system_prompt`
- إضافة قيمة افتراضية للـ System Prompt داخل `AppSettingsService.defaultSystemPrompt`.
- إضافة عمليات:
  - حفظ System Prompt من الواجهة.
  - استعادة System Prompt الافتراضي.
- تحديث `SettingsController` لإضافة:
  - `systemPromptController`
  - `saveSystemPrompt()`
  - `resetSystemPrompt()`
- إضافة سكشن جديد داخل إعدادات الموديل المحلي:
  - `SystemPromptSettingsSection`
- وضع السكشن بين سياسة تشغيل الموديل المحلي وبروفايلات الموديلات.
- استخدام reusable widgets الحالية بدل بناء UI مكرر:
  - `ReusableSurfaceCard`
  - `ReusableSettingsTextField`
  - `ReusableButton`
  - `ReusableText`
- تحديث `ReusableSettingsTextField` حتى لا يطبق فلتر الأرقام على الحقول النصية المتعددة الأسطر، وهذا ضروري حتى يقبل حقل System Prompt النص العربي الكامل.
- إضافة نصوص جديدة داخل `AppStrings` لعنوان ووصف وأزرار ورسائل System Prompt.

### ما تم تنفيذه في Rust Engine
- إضافة `system_prompt` داخل `EngineConfig`.
- إضافة default system prompt في Rust config.
- تطبيع System Prompt داخل config عند التحميل بحيث لا يكون فارغًا.
- تحديث `/settings` ليعيد `system_prompt` ضمن إعدادات engine.
- إضافة endpoint جديد:
  - `POST /runtime/system-prompt`
- تحديث `RuntimeManager.prepare_chat(...)` ليستخدم `system_prompt` فعليًا:
  - يأخذ `system_prompt` من الطلب إذا تم إرساله.
  - وإلا يستخدم `config.system_prompt`.
  - يحفظ عدد الحروف وpreview داخل Runtime snapshot.
  - يرجع داخل response معلومات تؤكد أن System Prompt تم تطبيقه.
- تحديث `RuntimeSnapshot` لإضافة:
  - `last_system_prompt_chars`
  - `last_system_prompt_preview`
- تحديث `RuntimeChatResponse` لإضافة:
  - `system_prompt_applied`
  - `system_prompt_chars`
  - `system_prompt_preview`
- تحديث `logixa_engine_config.example.json` لإضافة `system_prompt`.

### الملفات التي تم تعديلها
- `lib/app/data/services/app_settings_service.dart`
- `lib/app/modules/settings/controllers/settings_controller.dart`
- `lib/app/modules/settings/views/sections/local_model_settings_section.dart`
- `lib/app/widgets/reusable_widgets/reusable_settings_text_field.dart`
- `lib/app/constants/app_strings.dart`
- `logixa_engine/src/config.rs`
- `logixa_engine/src/routes.rs`
- `logixa_engine/src/runtime.rs`
- `logixa_engine/logixa_engine_config.example.json`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/modules/settings/views/sections/system_prompt_settings_section.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تنفيذ Step 10 في هذه الخطوة.
- لم يتم إضافة import/export من Markdown الآن؛ تم تأجيله كتحسين لاحق حتى لا يتوسع النطاق.
- لم يتم ربط Flutter فعليًا بإرسال System Prompt إلى Rust endpoints، لأن ربط Flutter Engine Client لم يتم اعتماده كخطوة مستقلة بعد.
- لم يتم تشغيل GGUF فعليًا.
- لم يتم إضافة SQLite أو Memory System.
- لم يتم إصلاح تحذير Flutter Linux عند الإغلاق لأنه غير blocker وظهر بعد ضغط زر الإغلاق.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

وفي terminal آخر:

```bash
curl -s http://127.0.0.1:8787/settings | python3 -m json.tool
```

اختبار حفظ System Prompt داخل Rust:

```bash
curl -X POST http://127.0.0.1:8787/runtime/system-prompt \
  -H "Content-Type: application/json" \
  -d '{"system_prompt":"أنت مساعد محلي داخل Logixa EDL AI. التزم بالوضوح والاختصار."}'
```

اختبار أن `/runtime/chat` يستخدم System Prompt المرسل في الطلب:

```bash
curl -X POST http://127.0.0.1:8787/runtime/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt":"اختبار System Prompt","system_prompt":"سيستم برومبت تجريبي من الطلب."}'
```

### الخطوة القادمة حسب الاتفاق
Step 10 — Memory System، وبعدها مراجعة شاملة:
- ما هو فعال 100%.
- ما هو UI فقط.
- ما هو Placeholder.
- ما يحتاج ربط.
- ما يحتاج تنظيف أو إصلاح.

---

## Step 10 — Memory System Skeleton

### الهدف
تنفيذ Step 10 المذكورة في `README.md` بشكل مبدئي ومنضبط:
- إنشاء Memory System داخل Rust Engine باستخدام SQLite.
- تجهيز تخزين محلي أولي للمحادثات والرسائل والذاكرة والخبراء وجلسات مساحة العمل.
- عدم ربط Flutter UI بالذاكرة بعد، وعدم تشغيل موديل GGUF فعليًا.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي قبل التنفيذ.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- الخطوة متوافقة مع Step 10 في `README.md`.
- لم يتم تعديل `README.md`.
- تم الالتزام بالاتفاق أن بعض المكونات قد تظل جزئية/Placeholder لحين مراجعة شاملة بعد Step 10.

### ما تم تنفيذه
- إضافة Memory Store داخل Rust Engine:
  - `logixa_engine/src/memory.rs`
- استخدام SQLite كذاكرة محلية أساسية للـ Engine.
- إضافة ملف قاعدة بيانات محلي افتراضي:
  - `logixa_engine_memory.sqlite`
- إضافة دعم متغير بيئة لتغيير مسار قاعدة الذاكرة:
  - `LOGIXA_ENGINE_MEMORY_DB`
- إضافة تهيئة تلقائية للجداول عند تشغيل الـ Engine.
- إضافة الجداول الأساسية:
  - `conversations`
  - `messages`
  - `memory_items`
  - `experts`
  - `workspace_sessions`
  - `selected_model_profile`
- إضافة endpoints مبدئية للذاكرة:
  - `GET /memory/status`
  - `GET /memory/conversations`
  - `POST /memory/conversations`
  - `GET /memory/messages?conversation_id=...`
  - `POST /memory/messages`
  - `GET /memory/items`
  - `POST /memory/items`
  - `GET /memory/experts`
  - `POST /memory/experts`
  - `GET /memory/workspace-sessions`
  - `POST /memory/workspace-sessions`
  - `GET /memory/selected-model-profile`
- تحديث `/runtime/profile` بحيث يحفظ Snapshot للبروفايل النشط داخل جدول `selected_model_profile`.
- تحديث `/status` ليعرض مسار قاعدة بيانات الذاكرة `memory_db_path`.
- تحديث `.gitignore` داخل `logixa_engine/` لتجاهل ملفات SQLite المحلية.
- إضافة dependencies داخل Rust Engine:
  - `rusqlite` مع `bundled`
  - `uuid`

### الملفات التي تم تعديلها
- `logixa_engine/Cargo.toml`
- `logixa_engine/.gitignore`
- `logixa_engine/src/main.rs`
- `logixa_engine/src/routes.rs`
- `logixa_engine/src/state.rs`
- `did.md`

### الملفات التي تم إضافتها
- `logixa_engine/src/memory.rs`

### ما لم يتم تنفيذه عمدًا
- لم يتم ربط Flutter UI بالـ Memory endpoints بعد.
- لم يتم تخزين رسائل `/runtime/chat` تلقائيًا في الذاكرة؛ تم تجهيز endpoints فقط.
- لم يتم تنفيذ بحث دلالي أو embeddings.
- لم يتم استخدام Firebase؛ يظل مؤجلًا كـ backup/sync وليس core memory.
- لم يتم تشغيل GGUF أو llama.cpp.
- لم يتم تعديل `README.md`.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

### اختبارات Rust Memory endpoints المقترحة
```bash
curl -s http://127.0.0.1:8787/memory/status | python3 -m json.tool
```

```bash
curl -s -X POST http://127.0.0.1:8787/memory/conversations \
  -H "Content-Type: application/json" \
  -d '{"title":"اختبار ذاكرة","workspace_path":"/tmp/logixa-test","model_profile_id":"gemma_fast_local","system_prompt":"سيستم برومبت تجريبي"}' | python3 -m json.tool
```

```bash
curl -s http://127.0.0.1:8787/memory/conversations | python3 -m json.tool
```

### الخطوة التالية بعد Step 10
حسب الاتفاق: بعد Step 10 نوقف إضافة Features جديدة ونعمل مراجعة شاملة منظمة:
- ما هو شغال فعليًا.
- ما هو UI فقط.
- ما هو Placeholder.
- ما يحتاج ربط.
- ما يحتاج تنظيف.
- ما قد يسبب مشاكل لاحقًا.
- ترتيب خطوات الإصلاح التالية قبل تشغيل الموديل الحقيقي.

---

## Post Step 10 Audit — README / did / Code Review + todo.md

### الهدف
تنفيذ مراجعة شاملة بعد Step 10 حسب الاتفاق:
- مقارنة الكود الحالي مع `README.md` و`did.md`.
- تحديد ما تم تنفيذه فعليًا.
- تحديد ما هو مكتمل مبدئيًا.
- تحديد ما هو Placeholder أو غير مربوط.
- كتابة الخطوات الناقصة والمنظمة في `todo.md`.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأساسي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- تمت مراجعة كود Flutter داخل `lib/`.
- تمت مراجعة كود Rust داخل `logixa_engine/`.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- إنشاء/تحديث ملف `todo.md` ليحتوي على:
  - ملخص الحالة الحالية.
  - مقارنة مباشرة مع خطوات `README.md`.
  - تصنيف ما هو شغال فعليًا وما هو جزئي وما هو Placeholder.
  - أهم الفجوات المعمارية الحالية.
  - خطوات مقترحة بعد Step 10 بداية من Step 11.
  - Cleanup items تحتاج قرار أو إذن لاحق.
- توثيق أن ربط Flutter بالـ Rust Engine هو الفجوة الأساسية التالية قبل تشغيل الموديل الحقيقي.
- توثيق أن Chat وData Center وTerminal وExtensions ما زالوا Placeholder/جزئيين.
- توثيق أن Memory System موجود في Rust لكن غير مربوط بالواجهة أو الشات بعد.

### الملفات التي تم تعديلها
- `todo.md`
- `did.md`

### الملفات التي لم يتم تعديلها عمدًا
- `README.md`
- كود Flutter داخل `lib/`
- كود Rust داخل `logixa_engine/`

### ملاحظات المراجعة
- النسخة المرفوعة لا تحتوي على `pubspec.yaml` أو `pubspec.lock` أو platform folders، لذلك فحص الباكدجات تم اعتمادًا على السياق السابق والملفات المتاحة فقط.
- لم يتم تشغيل `flutter analyze` أو `cargo check` داخل بيئة المراجعة الحالية لأن أدوات Flutter/Rust غير متاحة هنا.
- المراجعة لا تضيف Features جديدة؛ هي فقط تنظيم وتوثيق لما بعد Step 10.

### الخطوة القادمة المقترحة حسب `todo.md`
Step 11 — Flutter Engine Client + Engine Status Sync:
- إنشاء خدمة Flutter للتواصل مع Rust Engine باستخدام `dio`.
- قراءة `/health` و`/status` و`/settings` و`/runtime/status`.
- عرض حالة الـ Engine في الواجهة بدون تشغيل GGUF.

