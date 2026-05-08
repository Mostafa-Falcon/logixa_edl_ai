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

## Step 11 — Flutter Engine Client + Engine Status Sync

### الهدف
تنفيذ الخطوة التالية من `todo.md` بعد مراجعة ما بعد Step 10:
- ربط Flutter بالـ Rust Engine قراءة حالة فقط.
- عرض حالة الاتصال بالـ Engine في الواجهة بدون تغيير إعدادات الموديل.
- تثبيت جسر أولي باستخدام `dio` قبل مزامنة الإعدادات في Step 12.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع العالي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- تمت مراجعة `todo.md` باعتباره خريطة التنفيذ الحالية بعد المراجعة.
- الخطوة متوافقة مع Step 11 في `todo.md`.
- لم يتم تعديل `README.md`.
- لم يتم تغيير منطق إعدادات الموديل المحلي الموجودة في Flutter.

### ما تم تنفيذه
- إضافة موديل حالة للمحرك:
  - `EngineStatusModel`
- إضافة خدمة Flutter جديدة:
  - `EngineClientService`
- الخدمة تستخدم `dio` لقراءة endpoints التالية:
  - `GET /health`
  - `GET /status`
  - `GET /settings`
  - `GET /runtime/status`
- تسجيل `EngineClientService` في `main.dart` كخدمة دائمة.
- إضافة فحص أولي تلقائي عند تشغيل التطبيق.
- إضافة تحديث دوري بسيط كل 10 ثوانٍ لحالة الـ Engine.
- إضافة زر تحديث حالة Engine في TopBar.
- تحديث Badge في TopBar لعرض:
  - `Engine Online`
  - `Engine Offline`
  - `فحص المحرك`
- إضافة سكشن جديد داخل Settings:
  - `EngineStatusSection`
- السكشن يعرض:
  - حالة الاتصال.
  - اسم الخدمة.
  - الإصدار.
  - Runtime stage.
  - هل الموديل محمّل.
  - هل الموديل المحلي مفعّل في Rust.
  - البروفايل النشط من Rust.
  - uptime.
  - مسار config.
  - مسار SQLite memory إن وجد.
  - رسالة خطأ واضحة لو المحرك غير متصل.

### الملفات التي تم تعديلها
- `lib/main.dart`
- `lib/app/constants/app_strings.dart`
- `lib/app/widgets/app_core/controller/top_bar_controller.dart`
- `lib/app/widgets/app_core/view/sections/top_bar_title_section.dart`
- `lib/app/widgets/app_core/view/sections/top_bar_actions_section.dart`
- `lib/app/modules/settings/views/sections/local_model_settings_section.dart`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/data/models/engine_status_model.dart`
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/modules/settings/views/sections/engine_status_section.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم مزامنة إعدادات Flutter إلى Rust؛ هذا مكانه Step 12.
- لم يتم تشغيل GGUF فعليًا.
- لم يتم ربط Chat بـ `/runtime/chat`.
- لم يتم استخدام WebSocket أو streaming.
- لم يتم جعل Flutter يبدأ Rust Engine تلقائيًا؛ المطلوب الآن قراءة الحالة فقط.
- لم يتم تغيير إعدادات Model Profiles أو System Prompt الموجودة في Flutter.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

مع تشغيل Rust Engine في Terminal منفصل:
```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

ثم فتح التطبيق والتأكد من ظهور حالة:
```text
Engine Online
```

ولو الـ Engine متوقف، المفروض تظهر حالة:
```text
Engine Offline
```
بدون كراش.

### الخطوة القادمة حسب todo.md
Step 12 — Sync Local Model Settings to Rust:
- عند حفظ إعدادات الموديل من Flutter يتم إرسالها إلى `/runtime/profile`.
- عند حفظ System Prompt يتم إرسالها إلى `/runtime/system-prompt`.
- معالجة فشل الاتصال بدون كراش.

---

## Step 12 — Sync Local Model Settings to Rust

### الهدف
تنفيذ الخطوة التالية من `todo.md` بدون تعديل `README.md`:
- مزامنة إعدادات الموديل المحلي من Flutter إلى Rust Engine عند الحفظ.
- مزامنة System Prompt من Flutter إلى Rust Engine عند الحفظ أو الاستعادة.
- إضافة الحقول الناقصة قبل تشغيل GGUF الحقيقي حتى يكون بروفايل الموديل كاملًا.
- الحفاظ على Flutter `GetStorage` كـ UI cache، مع جعل Rust Engine هو مصدر الحقيقة التدريجي للإعدادات المهمة.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع العالي.
- تمت مراجعة `did.md` الحالي قبل التنفيذ.
- تمت مراجعة `todo.md` باعتباره خريطة التنفيذ الحالية بعد المراجعة.
- الخطوة متوافقة مع Step 12 في `todo.md`.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه في Flutter
- تحديث `EngineClientService` لإضافة عمليات مزامنة مباشرة مع Rust Engine:
  - `syncRuntimeProfile(...)` لإرسال إعدادات الموديل إلى `POST /runtime/profile`.
  - `syncSystemPrompt(...)` لإرسال السيستم برومبت إلى `POST /runtime/system-prompt`.
- إضافة نتيجة مزامنة خفيفة داخل نفس ملف الخدمة:
  - `EngineSyncResult`
- تحديث `SettingsController` بحيث:
  - عند حفظ إعدادات الموديل يتم الحفظ محليًا أولًا ثم إرسالها إلى Rust Engine.
  - عند حفظ System Prompt يتم الحفظ محليًا أولًا ثم إرسالها إلى Rust Engine.
  - عند استعادة System Prompt الافتراضي يتم مزامنته مع Rust Engine أيضًا.
  - لو Rust Engine غير متصل، يتم حفظ الإعدادات محليًا فقط مع رسالة واضحة بدون كراش.
- إضافة الحقول الناقصة إلى `ModelProfileModel`:
  - `repeatPenalty`
  - `presencePenalty`
  - `promptTemplate`
  - `modelRole`
  - `loadPolicy`
  - `ramPolicy`
- تحديث صفحة إعدادات البروفايل النشط لإظهار الحقول الجديدة.
- إضافة نصوص جديدة داخل `AppStrings` لرسائل المزامنة وحقول الإعدادات الجديدة.

### ما تم تنفيذه في Rust Engine
- تحديث `ModelProfileConfig` لدعم الحقول الجديدة:
  - `repeat_penalty`
  - `presence_penalty`
  - `prompt_template`
  - `model_role`
  - `load_policy`
  - `ram_policy`
- إضافة defaults وnormalization لهذه الحقول داخل Rust.
- إصلاح تكرار حقل `model_profile` داخل `RuntimeProfileResponse` في `routes.rs`.

### الملفات التي تم تعديلها
- `lib/app/data/models/model_profile_model.dart`
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/modules/settings/controllers/settings_controller.dart`
- `lib/app/modules/settings/views/sections/active_model_profile_form_section.dart`
- `lib/app/constants/app_strings.dart`
- `logixa_engine/src/model_profile.rs`
- `logixa_engine/src/routes.rs`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تشغيل GGUF فعليًا.
- لم يتم تنفيذ Chat UI.
- لم يتم تنفيذ Memory auto-save.
- لم يتم تنفيذ بروفايلات Gemma الجاهزة؛ مكانها Step 13.
- لم يتم جعل Flutter يشغل Rust Engine تلقائيًا؛ هذا قرار/خطوة منفصلة لاحقًا.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

مع تشغيل Rust Engine في Terminal منفصل:

```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

### اختبار يدوي مقترح
- افتح Settings.
- عدّل أي قيمة في Model Profile.
- اضغط حفظ الإعدادات.
- لو Rust Engine شغال، المفروض تظهر رسالة مزامنة ناجحة.
- افحص Rust:

```bash
curl -s http://127.0.0.1:8787/settings | python3 -m json.tool
```

وتأكد أن `active_model_profile` يحتوي على:

```text
repeat_penalty
presence_penalty
prompt_template
model_role
load_policy
ram_policy
```

### الخطوة القادمة حسب todo.md
Step 13 — Local Model Profiles Presets:
- إضافة Action لإنشاء بروفايلات Gemma 4B Fast وGemma 12B Quality بدون تشغيل موديل حقيقي.

---

## Step 12.1 — Dev Run Script

### الهدف
إضافة سكريبت تطوير بسيط لتشغيل Rust Engine وFlutter معًا أثناء التطوير، بدون تحويل Flutter نفسه إلى Engine Process Manager داخل التطبيق في هذه المرحلة.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع العالي.
- تمت مراجعة `did.md` كسجل تنفيذ.
- تمت مراجعة `todo.md` كخريطة الطريق الحالية بعد المراجعة.
- الخطوة متوافقة مع القرار الحالي: Dev Script الآن، وEngine Launcher لاحقًا بعد استقرار الربط.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- إضافة ملف:
  - `scripts/dev.sh`
- السكريبت يتحقق أولًا هل Rust Engine يعمل على:
  - `http://127.0.0.1:8787/health`
- إذا كان Engine يعمل بالفعل، يستخدمه بدون تشغيل نسخة ثانية.
- إذا لم يكن يعمل، يشغّل:
  - `cargo run`
  داخل `logixa_engine/`.
- ينتظر حتى يصبح Engine online قبل تشغيل Flutter.
- يشغّل Flutter على Linux افتراضيًا.
- عند إغلاق Flutter، يوقف Rust Engine فقط إذا كان السكريبت هو من شغّله.

### الملفات التي تم إضافتها
- `scripts/dev.sh`

### الملفات التي تم تعديلها
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تنفيذ Engine Launcher داخل Flutter.
- لم يتم تغيير Rust Engine.
- لم يتم تغيير إعدادات الموديل.
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.

### أوامر الفحص المطلوبة
```bash
bash -n scripts/dev.sh
flutter analyze
./scripts/dev.sh
```

### نتيجة التنفيذ عند مصطفى
- `flutter analyze` رجع:
  - `No issues found!`
- تم عمل commit:
  - `e129e46 step 12.1 add dev run script`
- تم رفع التاج:
  - `step12-1-dev-run-script`

### الخطوة القادمة حسب todo.md
Step 13 — Local Model Profiles Presets:
- إضافة Action لإنشاء بروفايلات Gemma 4B Fast وGemma 12B Quality بدون تشغيل موديل حقيقي.

---

## Step 13 — Local Model Profiles Presets

### الهدف
تنفيذ الخطوة التالية من `todo.md` بدون تعديل `README.md`:
- إضافة بروفايلات جاهزة للموديلات الموجودة محليًا.
- تجهيز بروفايل سريع لـ Gemma 3 4B.
- تجهيز بروفايل جودة أعلى لـ Gemma 3 12B.
- عدم تشغيل GGUF فعليًا في هذه الخطوة.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع العالي.
- تمت مراجعة `did.md` كسجل تنفيذ.
- تمت مراجعة `todo.md` باعتباره خريطة التنفيذ الحالية.
- الخطوة متوافقة مع Step 13 في `todo.md`.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- إضافة preset ثابت داخل `ModelProfileModel` لـ:
  - `Gemma 3 4B Fast`
  - `Gemma 3 12B Quality`
- إضافة مسارات نسبية للموديلات الحالية داخل المشروع:
  - `models/gemma3_abliterated_v2/gemma-3-4b-it-abliterated-v2.q4_k_m.gguf`
  - `models/gemma3_abliterated_v2/gemma-3-12b-it-abliterated-v2.q4_k_m.gguf`
- تثبيت إعدادات sampling الأساسية داخل البروفايلات الجاهزة:
  - `temperature = 1.0`
  - `top_p = 0.95`
  - `top_k = 64`
  - `repeat_penalty = 1.10`
  - `presence_penalty = 0.10`
- تثبيت Prompt Template المناسب لـ Gemma:
  - `<start_of_turn>user\n{system_prompt}\n\n{user_prompt}<end_of_turn>\n<start_of_turn>model`
- جعل بروفايل 4B بدور:
  - `model_role = fast`
  - `batch_size = 256`
  - `max_tokens = 512`
- جعل بروفايل 12B بدور:
  - `model_role = quality`
  - `batch_size = 128`
  - `max_tokens = 768`
- إضافة أزرار داخل قسم بروفايلات الموديلات:
  - إضافة Gemma 4B سريع.
  - إضافة Gemma 12B جودة.
- عند اختيار preset:
  - يتم حفظه كبروفايل نشط داخل Flutter.
  - يتم تحديث الفورم بنفس القيم.
  - يتم محاولة مزامنته مع Rust Engine عبر `/runtime/profile`.
  - لو Rust Engine غير متصل، يتم الحفظ محليًا فقط بدون كراش.
- استخدام نفس `ReusableButton` والتصميم الموحد بدون إنشاء UI منفصل.

### الملفات التي تم تعديلها
- `lib/app/data/models/model_profile_model.dart`
- `lib/app/modules/settings/controllers/settings_controller.dart`
- `lib/app/modules/settings/views/sections/model_profiles_section.dart`
- `lib/app/constants/app_strings.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تشغيل GGUF فعليًا.
- لم يتم تنفيذ `llama.cpp` adapter.
- لم يتم تنفيذ Runtime Model Router.
- لم يتم تغيير Memory System.
- لم يتم إضافة import/export Markdown.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

مع تشغيل Rust Engine في Terminal منفصل أو باستخدام `scripts/dev.sh`:

```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

اختبار يدوي مقترح:
- افتح Settings.
- اضغط `إضافة Gemma 4B سريع`.
- افحص أن البروفايل ظهر وأصبح نشطًا.
- اضغط `إضافة Gemma 12B جودة`.
- افحص أن البروفايل ظهر وأصبح نشطًا.
- مع تشغيل Rust، افحص:

```bash
curl -s http://127.0.0.1:8787/settings | python3 -m json.tool
```

### الخطوة القادمة حسب todo.md
Step 14 — Real Chat Page Skeleton:
- استبدال ChatPage placeholder بشاشة شات مبدئية.
- إرسال prompt إلى `/runtime/chat`.
- عرض response lifecycle message مؤقتًا بدون تشغيل GGUF فعلي.

---

## Step 14 — Real Chat Page Skeleton

### الهدف
تنفيذ الخطوة التالية من `todo.md` بدون تعديل `README.md`:
- تحويل `ChatPage` من Placeholder إلى شاشة شات مبدئية.
- إضافة Messages list.
- إضافة Text input وزر إرسال.
- دعم اختيار Profile يدويًا أو استخدام البروفايل النشط.
- إرسال الطلب إلى Rust Engine عبر `POST /runtime/chat`.
- عرض lifecycle response مؤقتًا فقط.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع العالي.
- تمت مراجعة `did.md` كسجل تنفيذ.
- تمت مراجعة `todo.md` باعتباره خريطة التنفيذ الحالية.
- الخطوة متوافقة مع Step 14 في `todo.md`.
- لم يتم تعديل `README.md`.

### ما تم تنفيذه
- إضافة route حقيقي لصفحة الشات:
  - `/chat-page`
- ربط زر الشات في Home Sidebar بفتح صفحة الشات.
- استبدال Placeholder داخل `ChatPageView` بواجهة شات مبدئية منظمة.
- إضافة `ChatPageController` لإدارة:
  - الرسائل.
  - حقل الإدخال.
  - حالة الإرسال.
  - اختيار البروفايل المستخدم.
  - إرسال الرسالة إلى Rust Runtime.
- إضافة موديل خفيف للرسائل:
  - `ChatMessageModel`
- إضافة method داخل `EngineClientService`:
  - `sendRuntimeChat(...)`
- إضافة نتيجة runtime خفيفة:
  - `EngineRuntimeChatResult`
- إضافة أقسام UI صغيرة بدل ملف واحد كبير:
  - `ChatHeaderSection`
  - `ChatProfileSelectorSection`
  - `ChatMessagesSection`
  - `ChatInputSection`
- إضافة reusable bubble للرسائل:
  - `ReusableChatBubble`
- عند اختيار بروفايل يدويًا قبل الإرسال:
  - يتم تعيينه كبروفايل نشط محليًا.
  - يتم محاولة مزامنته مع Rust عبر `/runtime/profile`.
  - لا يحدث كراش لو Rust Engine غير متصل.
- عند إرسال الرسالة:
  - يتم إرسال `prompt` و`system_prompt` إلى `/runtime/chat`.
  - يتم عرض lifecycle response فقط.

### الملفات التي تم تعديلها
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `lib/app/modules/home/controllers/home_controller.dart`
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/modules/chat_page/controllers/chat_page_controller.dart`
- `lib/app/modules/chat_page/views/chat_page_view.dart`
- `lib/app/modules/chat_page/bindings/chat_page_binding.dart`
- `lib/app/constants/app_strings.dart`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/data/models/chat_message_model.dart`
- `lib/app/modules/chat_page/views/sections/chat_header_section.dart`
- `lib/app/modules/chat_page/views/sections/chat_profile_selector_section.dart`
- `lib/app/modules/chat_page/views/sections/chat_messages_section.dart`
- `lib/app/modules/chat_page/views/sections/chat_input_section.dart`
- `lib/app/widgets/reusable_widgets/reusable_chat_bubble.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تشغيل GGUF فعليًا.
- لم يتم تنفيذ Streaming.
- لم يتم تنفيذ Tools.
- لم يتم تنفيذ Memory auto-save؛ مكانه Step 15.
- لم يتم تنفيذ Runtime GGUF Adapter أو llama.cpp.

### أوامر الفحص المطلوبة
```bash
flutter pub get
flutter analyze
flutter run -d linux
```

مع تشغيل Rust Engine في Terminal منفصل أو باستخدام:

```bash
./scripts/dev.sh
```

أو يدويًا:

```bash
cd logixa_engine
cargo fmt
cargo check
cargo run
```

اختبار يدوي مقترح:
- افتح التطبيق.
- افتح الشات من الـ Sidebar.
- اختار بروفايل Gemma 4B أو البروفايل النشط.
- اكتب رسالة قصيرة واضغط إرسال.
- المفروض تظهر رسالة lifecycle response بدون تشغيل GGUF حقيقي.

### الخطوة القادمة حسب todo.md
Step 15 — Auto-save Chat To Rust Memory:
- إنشاء conversation عند أول رسالة.
- حفظ رسالة المستخدم في SQLite Memory.
- حفظ رد Runtime/Assistant في SQLite Memory.
- إضافة metadata بدون تشغيل GGUF حقيقي.

---

## Step 14 — UI Alignment Hotfix / Runtime Layout Fix

### السبب
بعد تشغيل Step 14 ظهر أن التنفيذ الأول لم يحقق شرط الاستقرار البصري بنسبة 100%:
- صفحة الشات كانت مختلفة بصريًا عن أسلوب Home/Workspace.
- `ChatProfileSelectorSection` تسبب في RenderFlex overflow داخل Linux desktop.
- `scripts/dev.sh` كان يحتاج إعادة كتابة آمنة بسطور صحيحة وتشغيل مباشر.
- ظهر lint بسيط بسبب استخدام underscores متعددة.

### القاعدة
هذه ليست Step 15.
هذه مراجعة وتصحيح لنفس Step 14 قبل اعتمادها.
لم يتم تعديل `README.md`.
لم يتم تشغيل GGUF.
لم يتم إضافة Streaming أو Tools أو Memory auto-save.

### ما تم تعديله
- إعادة تنظيم `ChatPageView` إلى layout موحد:
  - Header.
  - Profile selector أفقي compact.
  - Messages area.
  - Input area.
- إزالة الـ fixed right sidebar الذي سبب الضغط والـ overflow.
- جعل `ChatProfileSelectorSection` responsive باستخدام `LayoutBuilder` و`Wrap` بدل Column طويلة مع Spacer.
- إصلاح lint `unnecessary_underscores` في `ChatMessagesSection`.
- إعادة كتابة `scripts/dev.sh` بصيغة Bash سليمة قابلة للتشغيل، مع fallback لو `curl` غير متاح.

### الملفات المعدلة
- `lib/app/modules/chat_page/views/chat_page_view.dart`
- `lib/app/modules/chat_page/views/sections/chat_profile_selector_section.dart`
- `lib/app/modules/chat_page/views/sections/chat_messages_section.dart`
- `scripts/dev.sh`
- `did.md`

### الفحص المطلوب
```bash
flutter analyze
flutter run -d linux
./scripts/dev.sh
```

### شرط اعتماد Step 14
لا يتم الانتقال إلى Step 15 إلا بعد:
- عدم وجود RenderFlex overflow.
- `flutter analyze` يعرض `No issues found!`.
- زر الشات يفتح صفحة موحدة بصريًا.
- اختيار البروفايل موجود.
- الإرسال إلى `/runtime/chat` يعمل كـ lifecycle response فقط.


---

## Step 14 Hotfix — توحيد الـ Navigation Shell قبل اعتماد الخطوة

### الهدف
تصحيح Step 14 قبل الانتقال لأي خطوة جديدة، بعد ظهور عدم اتساق واضح بين الصفحات في شريط التنقل الجانبي، وظهور صفحة الشات بتخطيط مختلف عن Home وSettings وWorkspace.

### ما تم تنفيذه
- إنشاء Navigation رئيسي موحد reusable لكل الصفحات:
  - `AppMainNavigation`
- نقل مسؤولية عرض شريط التنقل الرئيسي إلى `CorePage` بدل تكرارها داخل كل صفحة.
- توحيد ظهور الـ Activity Bar في:
  - Home
  - Workspace
  - Chat
  - Settings
- إزالة تكرار الـ Navigation المحلي من الصفحات:
  - `HomeSidebar`
  - `WorkspaceActivityBar`
  - شريط Settings اليدوي داخل `SettingsView`
- الإبقاء على Workspace panels كمنطقة عمل داخلية فقط، وليس Navigation رئيسي مستقل.
- عدم إضافة أي Feature جديدة خارج تصحيح Step 14.

### الملفات التي تم تعديلها
- `lib/app/widgets/core_page.dart`
- `lib/app/modules/home/views/home_view.dart`
- `lib/app/modules/work_space/views/work_space_view.dart`
- `lib/app/modules/settings/views/settings_view.dart`
- `did.md`

### الملفات التي تم إضافتها
- `lib/app/widgets/app_core/view/sections/app_main_navigation.dart`

### الملفات التي تم حذفها
- `lib/app/modules/home/views/sections/home_sidebar.dart`
- `lib/app/modules/work_space/views/sections/workspace_activity_bar.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تنفيذ Step 15.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تنفيذ Streaming.
- لم يتم تنفيذ Tools.
- لم يتم تغيير سياسة تشغيل الموديل.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

اختبار يدوي مطلوب قبل اعتماد Step 14:
- افتح Home وتأكد أن الشريط الجانبي ظاهر بنفس الشكل.
- افتح Chat وتأكد أن الشريط الجانبي ظاهر بنفس الشكل.
- افتح Settings وتأكد أن الشريط الجانبي ظاهر بنفس الشكل.
- افتح Workspace وتأكد أن الشريط الجانبي الرئيسي لم يعد متكررًا أو مختلفًا، وأن Explorer/Editor ما زالوا ظاهرين.
- تأكد من عدم وجود RenderFlex overflow.

### الحالة
Step 14 ما زالت في وضع التصحيح/الاعتماد، ولا يتم الانتقال إلى Step 15 إلا بعد تأكيد الشاشة والفحوصات.

---

## Step 14 Hotfix — Flutter Shell Cleanup قبل اعتماد Step 14

### السبب
بعد تشغيل Step 14 وتصحيح الـ Navigation ظهر أن اعتماد الخطوة غير مقبول بصريًا ووظيفيًا قبل تنظيف الـ Flutter Shell:
- زر/قسم الطرفية كان ظاهرًا في الـ Main Navigation رغم أن الطرفية جزء داخلي من Workspace/Code page.
- إعدادات/اختيار الموديل ظهرت داخل الشات رغم أن مصدر إعدادات الموديل يجب أن يكون Settings.
- تحديث حالة Rust Engine ظهر في أكثر من مكان بدل أن يكون مصدره الشريط العلوي.
- Workspace Bottom Panel أظهر RenderFlex overflow بسيط في Linux بسبب ارتفاع الـ collapsed panel.

### القرار
هذه ليست Step 15، ولا يتم الانتقال لأي خطوة جديدة.
هذا تصحيح اعتماد لنفس Step 14 حتى يصبح الـ UI موحدًا ومستقرًا.

### ما تم تنفيذه
- توحيد الـ Main Navigation ليعرض فقط الصفحات الحقيقية الحالية:
  - الرئيسية.
  - مساحة العمل.
  - الشات.
  - الإعدادات.
- إزالة عناصر الـ Navigation غير المكتملة/المكررة:
  - الطرفية من الـ main bar.
  - الداتا من الـ main bar.
  - الحساب من الـ main bar.
- نقل التحكم العملي في Rust Engine إلى الشريط العلوي:
  - لو المحرك Offline يظهر زر تشغيل من الـ Top Bar.
  - لو المحرك Online يتحول الزر إلى تحديث الحالة.
- إضافة تشغيل Rust Engine من Flutter عبر `cargo run` داخل `logixa_engine` بدون تشغيل GGUF.
- إزالة زر تحديث الحالة من صفحة الشات.
- إزالة اختيار/إعدادات الموديل من صفحة الشات، والاعتماد على البروفايل النشط من Settings عند الإرسال.
- إبقاء Settings كمكان عرض وتعديل إعدادات الموديل.
- إبقاء EngineStatusSection في Settings كعرض تفصيلي فقط، بدون زر تحديث مكرر.
- زيادة ارتفاع Workspace Bottom Panel collapsed لتفادي overflow في Linux.

### الملفات التي تم تعديلها
- `lib/app/widgets/app_core/view/sections/app_main_navigation.dart`
- `lib/app/widgets/app_core/controller/top_bar_controller.dart`
- `lib/app/widgets/app_core/view/sections/top_bar_actions_section.dart`
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/modules/chat_page/controllers/chat_page_controller.dart`
- `lib/app/modules/chat_page/views/chat_page_view.dart`
- `lib/app/modules/chat_page/views/sections/chat_header_section.dart`
- `lib/app/modules/settings/views/sections/engine_status_section.dart`
- `lib/app/constants/app_strings.dart`
- `lib/app/constants/app_sizes.dart`
- `did.md`

### الملفات التي تم حذفها
- `lib/app/modules/chat_page/views/sections/chat_profile_selector_section.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تنفيذ Step 15.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تنفيذ Streaming.
- لم يتم تنفيذ Tools.
- لم يتم تنفيذ Memory auto-save.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

اختبار يدوي قبل اعتماد Step 14:
- افتح Home وتأكد أن الـ navigation موحد.
- افتح Workspace وتأكد أن الطرفية ليست في الشريط الجانبي الرئيسي، وأنها موجودة فقط داخل Bottom Panel.
- افتح Chat وتأكد أن الشات لا يحتوي إعدادات موديل ولا زر تحديث حالة.
- افتح Settings وتأكد أن إعدادات الموديل موجودة هناك فقط.
- اضغط زر Rust Engine في الشريط العلوي والمحرك Offline، وتأكد أنه يحاول تشغيل Rust Engine.
- تأكد من عدم وجود RenderFlex overflow.

### الحالة
Step 14 ما زالت تحت الاعتماد، ولا يتم عمل commit/tag إلا بعد تأكيد مصطفى أن الواجهة أصبحت موحدة ومستقرة 100%.

---

## Step 14 Hotfix — Rust Engine Toggle + إيقاف المحرك عند إغلاق التطبيق

### السبب
بعد اعتماد شكل الـ Flutter Shell ظهر أن Rust Engine كان يفضل شغال بعد إغلاق التطبيق. هذا غير مقبول لأن التحكم في المحرك يجب أن يكون من الواجهة نفسها، وليس من Terminal أو `dev.sh`.

### القرار
لا يتم الانتقال إلى Step 15. هذا تصحيح أخير داخل Step 14 حتى يصبح التحكم في Rust Engine واضحًا ومغلقًا داخل الـ Top Bar.

### ما تم تنفيذه
- فصل أزرار Rust Engine في الـ Top Bar إلى:
  - زر تحديث حالة مستقل.
  - زر Toggle مستقل لتشغيل/إيقاف Rust Engine.
- عند Offline يظهر زر تشغيل Rust Engine.
- عند Online يتحول الزر إلى إيقاف Rust Engine.
- إضافة حالة `isStoppingEngine` حتى تظهر حالة الإيقاف ولا يتم الضغط أثناء العملية.
- تغيير تشغيل Rust Engine من `cargo run` إلى:
  - `cargo build` أولًا.
  - تشغيل binary مباشرة من `logixa_engine/target/debug/logixa_engine`.
  هذا يجعل العملية التي يشغلها Flutter قابلة للإيقاف المباشر بدل ترك child process شغال بعد إغلاق التطبيق.
- إضافة fallback على Linux/macOS لإيقاف العملية المرتبطة ببورت `8787` لو كانت عملية قديمة بدأت من نسخة سابقة أو خارج التطبيق.
- عند إغلاق التطبيق من زر الإغلاق أو حدث إغلاق النافذة يتم إيقاف Rust Engine قبل تدمير النافذة.
- إضافة `setPreventClose(true)` حتى يمر الإغلاق عبر مسار تنظيف واحد.
- تحديث Chat binding لضمان توفر `TopBarController` لو تم فتح صفحة الشات مباشرة.
- حذف `scripts/dev.sh` لأن التشغيل المعتمد أصبح من Flutter Top Bar بدل Terminal runner.

### الملفات التي تم تعديلها
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/widgets/app_core/controller/top_bar_controller.dart`
- `lib/app/widgets/app_core/view/sections/top_bar_actions_section.dart`
- `lib/app/modules/chat_page/bindings/chat_page_binding.dart`
- `lib/app/constants/app_strings.dart`
- `lib/main.dart`
- `did.md`

### الملفات التي تم حذفها
- `scripts/dev.sh`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تنفيذ Step 15.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تنفيذ Streaming.
- لم يتم تنفيذ Tools.
- لم يتم تنفيذ Memory auto-save.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

اختبار يدوي قبل اعتماد Step 14:
- افتح التطبيق والمحرك Offline.
- اضغط زر التشغيل من الشريط العلوي وتأكد أن Rust Engine يصبح Online.
- اضغط زر الإيقاف من الشريط العلوي وتأكد أن Rust Engine يصبح Offline.
- شغل المحرك مرة أخرى، ثم اقفل التطبيق من زر الإغلاق.
- افتح التطبيق مرة ثانية وتأكد أن Rust Engine لا يزال Offline إلا لو شغلته يدويًا.
- استخدم زر تحديث الحالة للتأكد من القراءة فقط.

### الحالة
Step 14 ما زالت تحت الاعتماد النهائي. لا commit/tag إلا بعد نجاح الفحص اليدوي أعلاه.

---

## Step 15 — Auto-save Chat To Rust Memory

### الهدف
تحويل الشات من رسائل مؤقتة داخل Flutter فقط إلى شات يحفظ كل محادثة ورسائلها في Rust Memory / SQLite.

### ما تم تنفيذه
- عند أول رسالة في صفحة الشات يتم إنشاء conversation في Rust Memory عبر:
  - `POST /memory/conversations`
- حفظ رسالة المستخدم بعد إنشاء المحادثة عبر:
  - `POST /memory/messages`
- حفظ رد الـ runtime/assistant بعد استدعاء:
  - `POST /runtime/chat`
  ثم:
  - `POST /memory/messages`
- استخدام نفس conversation id لباقي رسائل نفس جلسة الشات المفتوحة.
- إضافة metadata لكل رسالة محفوظة تشمل:
  - `workspace_path`
  - `active_model_profile_id`
  - `system_prompt_preview`
  - `runtime_stage`
  - `client_message_id`
  - `local_model_enabled`
  - `auto_start_on_message`
  - `allow_background_model`
- إظهار system warning داخل الشات لو تعذر حفظ جزء من المحادثة في Rust Memory، بدون كسر إرسال الرسالة أو إيقاف الشات.
- تحديث رسالة الترحيب في الشات لتوضيح أن الحفظ التلقائي في Rust Memory أصبح مفعّلًا.

### الملفات التي تم تعديلها
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/modules/chat_page/controllers/chat_page_controller.dart`
- `lib/app/constants/app_strings.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تنفيذ Data Center UI.
- لم يتم عرض قائمة المحادثات أو الرسائل من الذاكرة؛ هذا مؤجل لـ Step 16.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تنفيذ Streaming.
- لم يتم تنفيذ Tools.
- لم يتم تعديل Rust Engine لأن endpoints المطلوبة موجودة بالفعل.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### اختبار يدوي مطلوب قبل اعتماد Step 15
1. شغّل Rust Engine من الشريط العلوي.
2. افتح صفحة الشات.
3. اكتب رسالة واحدة واضغط إرسال.
4. تأكد أن رد الـ runtime ظهر عادي.
5. تأكد أن الرسائل اتحفظت في Rust Memory بفحص العدادات:

```bash
curl -s http://127.0.0.1:8787/memory/status
```

المتوقع بعد أول رسالة:
- `conversations` تزيد بمقدار 1.
- `messages` تزيد بمقدار 2 على الأقل، رسالة user ورسالة assistant.

### الحالة
Step 15 جاهزة للفحص والاعتماد بعد نجاح الاختبار اليدوي.

---

## Step 16 — Data Center / Memory UI

### الهدف
تنفيذ Step 16 من `todo.md` فقط:
- تشغيل زر مركز البيانات بدل Placeholder.
- إنشاء صفحة Memory / Data Center تعرض محتوى Rust Memory.
- استخدام Rust Memory endpoints الحالية بدون تغيير Rust Engine وبدون تشغيل GGUF.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأعلى ولم يتم تعديله.
- تمت مراجعة `did.md` لمعرفة آخر نقطة مستقرة: Step 15.
- تمت مراجعة `todo.md` وتحديد نطاق Step 16 فقط.

### ما تم تنفيذه
- إضافة صفحة جديدة:
  - `/data-center`
- إضافة Module مستقل:
  - `DataCenterBinding`
  - `DataCenterController`
  - `DataCenterView`
- ربط زر مركز البيانات من Home Quick Actions بالصفحة الجديدة بدل رسالة Placeholder.
- إضافة زر مركز البيانات إلى الـ navigation الموحد في `AppMainNavigation`.
- إضافة موديلات قراءة خفيفة لبيانات Rust Memory:
  - status summary
  - conversations
  - messages
  - memory items
  - experts
  - workspace sessions
  - selected model profile snapshot
- توسيع `EngineClientService` لقراءة endpoints التالية:
  - `GET /memory/status`
  - `GET /memory/conversations`
  - `GET /memory/messages?conversation_id=...`
  - `GET /memory/items`
  - `GET /memory/experts`
  - `GET /memory/workspace-sessions`
  - `GET /memory/selected-model-profile`
- عرض Counters أساسية للذاكرة.
- عرض قائمة المحادثات المحفوظة.
- عرض رسائل المحادثة المختارة.
- عرض Snapshot للبروفايل النشط، وقاعدة الذاكرة، وملخص العناصر/الخبراء/مساحات العمل.
- الحفاظ على نفس `CorePage` والـ Navigation الموحد والستايل العام.

### الملفات التي تم تعديلها
- `did.md`
- `lib/app/constants/app_strings.dart`
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/modules/home/controllers/home_controller.dart`
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`
- `lib/app/widgets/app_core/view/sections/app_main_navigation.dart`

### الملفات التي تم إضافتها
- `lib/app/data/models/memory_dashboard_model.dart`
- `lib/app/modules/data_center/bindings/data_center_binding.dart`
- `lib/app/modules/data_center/controllers/data_center_controller.dart`
- `lib/app/modules/data_center/views/data_center_view.dart`
- `lib/app/modules/data_center/views/sections/data_center_header_section.dart`
- `lib/app/modules/data_center/views/sections/data_center_overview_section.dart`
- `lib/app/modules/data_center/views/sections/data_center_content_section.dart`
- `lib/app/modules/data_center/views/sections/data_center_conversations_section.dart`
- `lib/app/modules/data_center/views/sections/data_center_messages_section.dart`
- `lib/app/modules/data_center/views/sections/data_center_snapshot_section.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تشغيل GGUF.
- لم يتم إضافة Streaming.
- لم يتم إضافة Tools.
- لم يتم تسجيل Workspace Sessions؛ هذا مؤجل لـ Step 17.
- لم يتم إنشاء Memory Items أو Experts من Flutter؛ هذه الصفحة تعرض الموجود فقط.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### اختبار Step 16
1. شغّل Rust Engine من الشريط العلوي.
2. افتح مركز البيانات من Quick Actions أو الـ Sidebar.
3. اضغط `تحديث الذاكرة`.
4. تأكد أن counters تظهر.
5. تأكد أن المحادثات المحفوظة من Step 15 تظهر.
6. اختار محادثة وتأكد أن رسائلها تظهر.

### الخطوة القادمة حسب `todo.md`
Step 17 — Workspace Sessions Sync.

---

## Step 17 — Workspace Sessions Sync

### الهدف
ربط صفحة مساحة العمل بـ Rust Memory حتى يتم تسجيل جلسة Workspace عند فتح مساحة عمل، وتحديثها/إضافة جلسة جديدة عند فتح ملف أو تغيير الملف النشط.

### ما تم تنفيذه
- إضافة method في `EngineClientService` لإرسال جلسات مساحة العمل إلى:
  - `POST /memory/workspace-sessions`
- إضافة result model مبسط لنتيجة حفظ جلسة Workspace.
- مزامنة Workspace عند:
  - تحميل مساحة العمل.
  - تحديث مساحة العمل.
  - فتح ملف.
  - تغيير التبويب النشط.
  - إغلاق التبويب النشط.
- إرسال metadata مفيدة مع الجلسة:
  - `event`
  - `opened_file_count`
  - `opened_files`
  - `workspace_file_count`
  - حالة side/bottom panels
- تحديث عرض Data Center ليُظهر معلومات أوضح عن workspace sessions:
  - مسار Workspace.
  - الملف النشط.
  - عدد الملفات المفتوحة.

### الملفات المعدلة
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `lib/app/data/models/memory_dashboard_model.dart`
- `lib/app/modules/data_center/views/sections/data_center_snapshot_section.dart`
- `lib/app/constants/app_strings.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تنفيذ Terminal حقيقي.
- لم يتم تنفيذ Context Menu.
- لم يتم تعديل Rust Engine schema؛ تم استخدام endpoint الموجود بالفعل.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### اختبار يدوي مطلوب
- شغّل Rust Engine من الشريط العلوي.
- افتح Workspace.
- افتح ملف من Explorer.
- افتح مركز البيانات.
- اضغط تحديث الذاكرة.
- تأكد أن `Workspace Sessions` زادت وظهر آخر workspace/active file.

### الحالة
بانتظار فحص مصطفى ونتيجة `flutter analyze` وصورة Data Center قبل اعتماد Step 17.

---

## Fix Step — Step 17 Data Center Snapshot Build Error

### الهدف
إصلاح أخطاء `flutter analyze` و `flutter run -d linux` التي ظهرت بعد تطبيق Step 17 فقط، بدون إضافة Feature جديدة وبدون تعديل `README.md` أو `todo.md`.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأعلى.
- تمت مراجعة `did.md` لمعرفة آخر نقطة: Step 17 — Workspace Sessions Sync.
- تمت مراجعة `todo.md` للتأكد أن الإصلاح داخل نطاق Step 17 وليس خطوة جديدة.

### سبب المشكلة
كان ملف `data_center_snapshot_section.dart` يحتوي على string متعددة السطور مكتوبة داخل single quotes، مما سبب:
- `Unterminated string literal`
- أخطاء parser متتابعة داخل `_InfoBlock`
- تحذيرات وهمية عن variables غير مستخدمة بسبب فشل التحليل قبل اكتمال قراءة الكود.

### ما تم تنفيذه
- استبدال الـ multiline single-quoted string بقائمة سطور واضحة يتم تجميعها بواسطة `join('\n')`.
- تمرير قيمة جاهزة باسم `sessionDetails` إلى `_InfoBlock.value`.
- الحفاظ على نفس عرض معلومات Workspace Session:
  - مسار Workspace.
  - الملف النشط أو رسالة عدم وجود ملف نشط.
  - عدد الملفات المفتوحة.

### الملفات التي تم تعديلها
- `lib/app/modules/data_center/views/sections/data_center_snapshot_section.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تغيير `EngineClientService`.
- لم يتم تغيير `WorkSpaceController`.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تنفيذ Terminal أو Context Menu.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### الحالة
هذا إصلاح مباشر لكسر البناء في Step 17. بعد نجاح الفحص، يتم اعتماد Step 17 ثم عمل commit/tag.

---

## Step 17 QA Cleanup — Workspace Code Style Unification

### الهدف
تنظيف ملاحظات ما بعد فحص Step 17 بدون توسيع السكوب:
- نقل رسائل Workspace الظاهرة للمستخدم من `WorkSpaceController` إلى `AppStrings`.
- توحيد fallback اسم Workspace في Data Center عبر `AppStrings` بدل hardcoded string.
- تحويل مفاتيح metadata وأسماء أحداث Workspace Sessions إلى private constants بدل strings متناثرة داخل الدوال.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` كمرجع أعلى ولم يتم تعديله.
- تمت مراجعة `did.md` لمعرفة آخر حالة: Step 17 مع نجاح الفحص اليدوي بعد fix.
- تمت مراجعة `todo.md` والتأكد أن هذا تنظيف داخل حدود Step 17 وليس Step جديدة وظيفيًا.

### ما تم تنفيذه
- إضافة strings جديدة في `AppStrings` لرسائل Workspace logs/errors/preview/fallback.
- تحديث `WorkSpaceController` لاستخدام `AppStrings` لكل الرسائل الظاهرة للمستخدم.
- إضافة private constants داخل `WorkSpaceController` لأحداث Workspace Session وmetadata keys.
- تحديث `DataCenterSnapshotSection` لاستخدام `AppStrings.memoryWorkspaceFallbackName`.
- تحديث `MemoryWorkspaceSessionSummary` لاستخدام private constants عند قراءة metadata.
- الحفاظ على نفس endpoint ونفس schema ونفس سلوك Step 17.

### الملفات المعدلة
- `lib/app/constants/app_strings.dart`
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `lib/app/modules/data_center/views/sections/data_center_snapshot_section.dart`
- `lib/app/data/models/memory_dashboard_model.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تعديل Rust Engine schema.
- لم يتم إضافة Package جديد.
- لم يتم تغيير تصميم الواجهة أو إضافة Features جديدة.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### اختبار يدوي مطلوب
- افتح Workspace.
- افتح ملف.
- افتح Data Center.
- اضغط تحديث الذاكرة.
- تأكد أن Workspace Sessions تظهر، وأن active file وعدد الملفات المفتوحة ظاهرين.

### الحالة
جاهزة للفحص. إذا نجح `flutter analyze` واشتغل التطبيق، يتم اعتماد Step 17 بالكامل ثم commit/tag.

---

## Step 18 — Workspace Context Menu

### الهدف
تنفيذ Step 18 من `todo.md` فقط: إضافة context menu على عناصر شجرة ملفات Workspace باستخدام `super_context_menu`، بدون تنفيذ إنشاء/إعادة تسمية/حذف وبدون تعديل Rust Engine أو تشغيل GGUF.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأعلى ولم يتم تعديله.
- تمت مراجعة `did.md` لمعرفة آخر نقطة مستقرة: Step 17 بعد QA cleanup.
- تمت مراجعة `todo.md` وتحديد نطاق Step 18 فقط.

### ما تم تنفيذه
- إضافة `ContextMenuWidget` حول كل عنصر في شجرة ملفات Workspace.
- إضافة actions آمنة فقط حسب نطاق Step 18:
  - فتح الملف أو فتح/طي المجلد.
  - نسخ مسار الملف/المجلد إلى Clipboard.
  - إظهار مكان الملف/المجلد في مدير ملفات النظام.
  - تحديث شجرة Workspace.
- إضافة methods في `WorkSpaceController` لتنفيذ أوامر القائمة بدل وضع logic داخل الواجهة.
- إضافة رسائل وأسماء actions في `AppStrings` بدل hardcoded strings داخل الواجهة.
- استخدام `super_context_menu` الموجود مسبقًا في `pubspec.yaml` بدون إضافة package جديد.

### الملفات التي تم تعديلها
- `lib/app/constants/app_strings.dart`
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `lib/app/modules/work_space/views/sections/workspace_file_explorer.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تنفيذ Create/Rename/Delete لأنها مؤجلة لحين تثبيت الأمان.
- لم يتم تنفيذ Terminal الحقيقي.
- لم يتم تنفيذ محرر كود حقيقي.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تعديل Rust Engine.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### اختبار يدوي مطلوب
- افتح Workspace.
- اضغط Right Click على ملف وتأكد أن القائمة تظهر.
- جرّب `فتح` على ملف وتأكد أنه يفتح في التبويب.
- جرّب `نسخ المسار` ثم الصقه في Terminal أو ملف نصي للتأكد.
- جرّب `إظهار في مدير الملفات` وتأكد أن مدير الملفات يفتح على مكان العنصر.
- جرّب `تحديث الشجرة` وتأكد أن الملفات ما زالت ظاهرة بدون crash.
- جرّب Right Click على مجلد وتأكد أن `فتح` يفتح/يطوي المجلد.

### الحالة
جاهزة للفحص والاعتماد بعد نجاح `flutter analyze` والتجربة اليدوية.

---

## Step 19 — Real Terminal

### الهدف
تحويل تبويب Terminal في اللوحة السفلية من placeholder إلى طرفية حقيقية مبدئية داخل Workspace الحالي باستخدام `xterm` و `flutter_pty`.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` باعتباره المرجع الأعلى ولم يتم تعديله.
- تمت مراجعة `did.md` لمعرفة آخر نقطة: Step 18 Context Menu جاهزة وتم فحصها واعتمادها من مصطفى قبل طلب Step 19.
- تمت مراجعة `todo.md` وتحديد نطاق Step 19 فقط.

### ما تم تنفيذه
- إضافة طرفية حقيقية داخل Bottom Panel / Terminal باستخدام `TerminalView` من `xterm`.
- تشغيل shell محلي باستخدام `Pty.start` من `flutter_pty`.
- تشغيل الطرفية داخل `activeWorkspace.path` عبر `workingDirectory`.
- إضافة أزرار آمنة في واجهة الطرفية:
  - تشغيل.
  - إيقاف.
  - إعادة تشغيل.
- منع إدخال المستخدم في الطرفية عندما تكون متوقفة عبر `readOnly`.
- ربط إدخال `xterm` بعملية `flutter_pty` بدون تشغيل أوامر تلقائيًا.
- ربط خرج `flutter_pty` بالـ `TerminalView` مع UTF-8 decoder آمن.
- ضبط resize مبدئي بين `xterm` و `pty`.
- تنظيف العملية عند إغلاق Controller حتى لا تبقى عملية terminal معلقة.
- نقل نصوص الطرفية الجديدة إلى `AppStrings`.
- فصل واجهة الطرفية في ملف مستقل للحفاظ على تنظيم Workspace UI.

### الملفات المعدلة
- `lib/app/constants/app_strings.dart`
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `lib/app/modules/work_space/views/sections/workspace_bottom_panel.dart`
- `lib/app/modules/work_space/views/sections/workspace_terminal_panel.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تشغيل أوامر تلقائيًا داخل الطرفية.
- لم يتم تنفيذ Terminal command presets.
- لم يتم تنفيذ auto-run لأي أمر بناء أو تحليل.
- لم يتم تعديل Rust Engine.
- لم يتم تشغيل GGUF الحقيقي.
- لم يتم تنفيذ Code Editor الحقيقي.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### اختبار يدوي مطلوب
- افتح Workspace.
- افتح تبويب Terminal من اللوحة السفلية.
- اضغط تشغيل.
- اكتب:
  - `pwd`
  - `ls`
- تأكد أن `pwd` يطابق مسار الـ Workspace المفتوح.
- اضغط إيقاف وتأكد أن الإدخال يتوقف.
- اضغط إعادة تشغيل وتأكد أن الطرفية تعمل من جديد.

### الحالة
جاهزة للفحص والاعتماد بعد نجاح `flutter analyze` والتجربة اليدوية.


---

## Step 19 Fix — xterm 4 import + analyzer cleanup

Goal:
Fix Step 19 build/analyzer issues after applying the real workspace terminal patch.

What changed:
- Updated the terminal view import from the removed `package:xterm/flutter.dart` entrypoint to `package:xterm/xterm.dart`, which exports `TerminalView` in xterm 4.0.0.
- Removed the unnecessary `dart:typed_data` import from `WorkSpaceController`.
- Removed the unused optional constructor parameter from the private `_TerminalShell` helper while preserving the shell argument list used by `Pty.start`.

Files changed:
- `lib/app/modules/work_space/views/sections/workspace_terminal_panel.dart`
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `did.md`

Scope control:
- No README edits.
- No todo edits.
- No Rust Engine changes.
- No GGUF changes.
- No terminal behavior expansion beyond fixing Step 19 compile/analyzer errors.

Checks to run:
- `flutter analyze`
- `flutter run -d linux`

Next step:
- If checks pass and the terminal opens inside the active workspace, commit/tag Step 19.

---

## Step 19 Fix — Terminal panel overflow guard

Goal:
Fix the runtime render overflow that appeared after Step 19 when the bottom panel body briefly receives a very small height during layout/animation.

What changed:
- Added a `LayoutBuilder` guard to `WorkspaceTerminalPanel` so the terminal body does not render its toolbar/view while the available height is below the safe minimum.
- Wrapped the terminal column with `ClipRect` for safer animated/collapsed panel rendering.
- Preserved the existing terminal behavior, xterm integration, flutter_pty wiring, and workspace working-directory logic.

Files changed:
- `lib/app/modules/work_space/views/sections/workspace_terminal_panel.dart`
- `did.md`

Scope control:
- No README edits.
- No todo edits.
- No Rust Engine changes.
- No GGUF changes.
- No terminal command behavior expansion.
- No new packages.

Checks to run:
- `flutter analyze`
- `flutter run -d linux`

Manual test:
- Open a Workspace.
- Open the Terminal bottom tab.
- Press تشغيل.
- Run `pwd` and confirm it matches the workspace path.
- Collapse/open the bottom panel and confirm no RenderFlex overflow appears.

Next step:
- If checks pass and no overflow appears, commit/tag Step 19.

---

## Step 20 — Real Code Editor

### الهدف
تحويل مساحة معاينة الملفات في Workspace إلى محرر كود فعلي قابل للتعديل والحفظ باستخدام `flutter_code_editor`، مع حماية الملفات الكبيرة والـ binary.

### ما تم تنفيذه
- استبدال معاينة النص القديمة بمحرر `CodeField` داخل ملف مستقل:
  - `lib/app/modules/work_space/views/sections/workspace_code_editor.dart`
- إضافة دعم تعديل محتوى الملف النشط داخل `WorkSpaceController`.
- إضافة زر حفظ في Header مساحة التحرير.
- إضافة حالة الملف في الواجهة:
  - محفوظ
  - غير محفوظ
  - قراءة فقط
  - جاري الحفظ
- إضافة مؤشر تعديلات غير محفوظة على تبويب الملف المفتوح.
- حماية الملفات الكبيرة والـ binary من التحرير والحفظ.
- حفظ الملف فعليًا على نفس المسار باستخدام `File.writeAsString`.
- تحديث محتوى التبويب وحجم الملف بعد الحفظ.
- تسجيل لوج عند فتح/حفظ/فشل حفظ/إغلاق ملف بتعديلات غير محفوظة.

### الملفات المعدلة
- `did.md`
- `lib/app/constants/app_strings.dart`
- `lib/app/modules/work_space/controllers/work_space_controller.dart`
- `lib/app/modules/work_space/views/sections/workspace_editor_area.dart`

### الملفات المضافة
- `lib/app/modules/work_space/views/sections/workspace_code_editor.dart`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم إضافة Packages جديدة.
- لم يتم إضافة Syntax language routing متقدم.
- لم يتم إضافة confirmation dialog عند إغلاق تبويب غير محفوظ.
- لم يتم إضافة autosave.
- لم يتم تشغيل أو تعديل GGUF.
- لم يتم تعديل Rust Engine.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### اختبار يدوي مطلوب
1. افتح Workspace.
2. افتح ملف نصي صغير مثل `.dart` أو `.md`.
3. عدّل سطر داخل المحرر.
4. تأكد أن حالة الملف أصبحت `غير محفوظ` وأن التبويب عليه مؤشر.
5. اضغط `حفظ`.
6. تأكد أن الحالة رجعت `محفوظ`.
7. افتح Terminal واكتب `cat path/to/file` أو افتح الملف من النظام للتأكد أن التعديل اتحفظ.
8. جرّب فتح ملف كبير أو binary وتأكد أن الحفظ غير متاح.

### الحالة
بانتظار فحص مصطفى ونتيجة `flutter analyze` قبل اعتماد Step 20.

---

## Step 21 — Runtime GGUF Adapter Planning

### الهدف
تثبيت قرار تشغيل GGUF الحقيقي قبل كتابة كود التشغيل، وتحديد حدود Step 22 بشكل آمن وقابل للاختبار.

### ما تم تنفيذه
- إضافة وثيقة تخطيط مستقلة:
  - `docs/runtime_gguf_adapter_plan.md`
- تثبيت القرار التنفيذي:
  - استخدام `llama.cpp` process manager داخل Rust Engine.
  - البدء بـ non-streaming.
  - تشغيل الموديل on-demand فقط.
  - `unload_after_response = true` كافتراضي.
  - البدء بموديل Gemma 3 4B فقط.
  - تأجيل 12B لحد ما 4B يثبت بدون freeze أو ضغط RAM.
- تحديد شكل Adapter المقترح داخل Rust.
- تحديد الإعدادات المطلوبة قبل Step 22.
- تثبيت سياسة عدم وجود hardcoded model paths.
- تحديد Prompt Template policy لـ Gemma.
- تحديد runtime states والأخطاء المطلوبة.
- تحديد حدود Step 22 بوضوح.

### الملفات المضافة
- `docs/runtime_gguf_adapter_plan.md`

### الملفات المعدلة
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم تشغيل GGUF.
- لم يتم تعديل Rust Engine.
- لم يتم تعديل Flutter UI.
- لم يتم إضافة Packages.
- لم يتم تشغيل 12B.
- لم يتم إضافة streaming.

### الفحص المطلوب
```bash
flutter analyze
git status --short
```

### الحالة
بانتظار مراجعة مصطفى واعتماد Step 21 قبل تنفيذ Step 22.

---

## Step 22 — Rust-managed llama-server GGUF Adapter

### الهدف
تنفيذ أول ربط حقيقي لتشغيل GGUF من Rust Engine، باستخدام `llama-server` كـ primary adapter بدل `llama-cli`، مع الحفاظ على Flutter كواجهة تحكم فقط.

### مراجعة قبل التنفيذ
- تم الالتزام بقرار التشغيل:
  - Primary: `llama-server` managed by Rust.
  - Fallback/debug: `llama-cli` فقط لاحقًا عند الحاجة.
  - Future: direct `llama.cpp` C API بعد الاستقرار.
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم إضافة UI جديدة.
- لم يتم تشغيل 12B.
- لم يتم إضافة streaming.

### ما تم تنفيذه
- استبدال mock lifecycle داخل `logixa_engine/src/runtime.rs` بتشغيل حقيقي مبدئي عبر `llama-server`.
- `RuntimeManager` أصبح يدير child process محلي لـ `llama-server`.
- قراءة مسار GGUF من `active_model_profile.model_path` فقط.
- رفض التشغيل عند:
  - `local_model_enabled = false`
  - `auto_start_on_message = false`
  - prompt فاضي
  - عدم وجود active model profile
  - عدم وجود model path
  - model path غير موجود على الجهاز
- تشغيل `llama-server` على `127.0.0.1:8788` افتراضيًا.
- إضافة دعم متغيرات البيئة:
  - `LOGIXA_LLAMA_SERVER_BIN`
  - `LOGIXA_LLAMA_SERVER_PORT`
  - `LOGIXA_LLAMA_SERVER_URL`
- استدعاء endpoint:
  - `POST /v1/chat/completions`
- أول تنفيذ non-streaming فقط.
- احترام policy:
  - `unload_after_response = true`
  - `keep_model_loaded = false`
- تحديث Runtime stages إلى حالات أوضح:
  - idle
  - starting
  - ready
  - generating
  - stopping
  - stopped
  - completed
  - error
- إضافة `reqwest` للاتصال الداخلي مع `llama-server`.
- تحديث خطة `docs/runtime_gguf_adapter_plan.md` لتثبيت قرار `llama-server`.

### الملفات التي تم تعديلها
- `logixa_engine/Cargo.toml`
- `logixa_engine/src/runtime.rs`
- `docs/runtime_gguf_adapter_plan.md`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل Flutter UI.
- لم يتم إضافة streaming.
- لم يتم تشغيل 12B.
- لم يتم استخدام `llama-cli` كمسار أساسي.
- لم يتم إدخال direct C API.
- لم يتم إضافة auto-save لرسائل `/runtime/chat` داخل الذاكرة؛ هذا مؤجل لخطوة منفصلة بعد ثبات inference.

### أوامر الفحص المطلوبة
```bash
flutter analyze

cd logixa_engine
cargo fmt
cargo check
cargo run
```

### اختبار يدوي مقترح
```bash
curl -s -X POST http://127.0.0.1:8787/runtime/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt":"رد بجملة قصيرة: النظام شغال؟"}' | python3 -m json.tool
```

لو `llama-server` ليس في PATH:
```bash
export LOGIXA_LLAMA_SERVER_BIN="/path/to/llama-server"
```

### الخطوة التالية
Step 23 يجب أن تكون تثبيت/تنظيف حسب نتيجة اختبار Step 22:
- لو التشغيل نجح: نربط Chat UI بالرد الحقيقي أو نحفظ الرسائل في Memory.
- لو التشغيل فشل: نصلح مسار `llama-server` أو arguments أو endpoint بدون توسيع السكوب.

---

## Step 22 Fix — User-selected GGUF Path + llama-server Maintenance Guard

### الهدف
إصلاح Step 22 قبل اعتمادها حتى لا يعتمد تشغيل GGUF على أي مسار موديل ثابت أو preset قديم داخل الكود، ويصبح مسار الموديل مسؤولية المستخدم من Flutter Settings فقط.

### مراجعة قبل التنفيذ
- تمت مراجعة `README.md` كمرجع أعلى.
- تمت مراجعة `did.md` قبل التنفيذ.
- تمت مراجعة `todo.md` قبل التنفيذ.
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- هذا Fix داخل Step 22 وليس Step جديدة.

### ما تم تنفيذه
- إزالة مسارات Gemma GGUF الثابتة من presets داخل Flutter model profile.
- جعل presets تنشئ بروفايل إعدادات فقط بدون `model_path`.
- تنظيف أي مسارات preset قديمة مخزنة مثل:
  - `models/gemma3_abliterated_v2/gemma-3-4b-it-abliterated-v2.q4_k_m.gguf`
  - `models/gemma3_abliterated_v2/gemma-3-12b-it-abliterated-v2.q4_k_m.gguf`
- إلزام Rust Runtime بأن يكون `model_path` مسارًا مطلقًا absolute path، حتى يأتي من اختيار المستخدم في Flutter File Picker أو إدخال واضح.
- منع تشغيل 12B مؤقتًا في Step 22 حسب قرار الخطة: 4B أولًا فقط.
- إضافة فحص واضح لـ `llama-server` قبل محاولة التشغيل.
- إذا كان `llama-server` غير موجود في PATH أو `LOGIXA_LLAMA_SERVER_BIN` غير مضبوط، يرجع Runtime رسالة maintenance واضحة بدل فشل مبهم:
  - `llama_server_bin_not_found: runtime_in_maintenance_until_llama_server_is_installed_or_LOGIXA_LLAMA_SERVER_BIN_is_configured`
- الحفاظ على عدم تشغيل أي أوامر تلقائية.
- الحفاظ على non-streaming فقط.
- الحفاظ على Rust-managed llama-server adapter بدون Flutter UI جديدة.

### الملفات التي تم تعديلها
- `lib/app/data/models/model_profile_model.dart`
- `lib/app/data/services/app_settings_service.dart`
- `logixa_engine/src/runtime.rs`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تثبيت `llama-server`.
- لم يتم تعديل Rust schema خارج Runtime guard.
- لم يتم تشغيل inference حقيقي بعد.
- لم يتم إضافة UI جديدة.
- لم يتم تغيير README أو todo.

### أوامر الفحص المطلوبة
```bash
flutter analyze

cd logixa_engine
cargo fmt
cargo check
cargo run
```

وفي Terminal آخر:

```bash
curl -i -X POST http://127.0.0.1:8787/runtime/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt":"رد بجملة قصيرة: النظام شغال؟"}'
```

### النتيجة المتوقعة قبل تثبيت llama-server
- لو لم يتم اختيار موديل من Flutter:
  - `missing_model_path`
- لو المسار نسبي أو preset قديم:
  - `model_path_must_be_absolute`
- لو تم اختيار 12B:
  - `model_temporarily_blocked_12b_use_4b_first`
- لو تم اختيار 4B صحيح لكن `llama-server` غير موجود:
  - `llama_server_bin_not_found: runtime_in_maintenance_until_llama_server_is_installed_or_LOGIXA_LLAMA_SERVER_BIN_is_configured`

### الخطوة التالية
بعد تثبيت أو تحديد مسار `llama-server`، يتم اختبار inference فعلي على موديل 4B فقط، ثم اعتماد Step 22 commit/tag.

## Step 23 Fix — System Prompt Source Control

### الهدف
إيقاف أي System Prompt افتراضي أو مخفي، والتأكد أن الـ System Prompt لا يطبق إلا إذا كان المستخدم حفظه صراحة من Flutter Settings أو أرسله صراحة في طلب runtime.

### ما تم تغييره
- جعل `defaultSystemPrompt` في Flutter فارغًا بدل نص افتراضي ثابت.
- جعل `resetSystemPrompt()` يمسح القيمة بدل إرجاع نص افتراضي.
- جعل قراءة System Prompt الفارغ ترجع قيمة فارغة وليس default.
- تعديل Rust Runtime بحيث لا يضيف رسالة `system` إلى طلب `llama-server` إذا كان الـ prompt فارغًا.
- جعل `system_prompt_applied=false` و `system_prompt_chars=0` و `system_prompt_preview=null` عند عدم وجود prompt فعلي.
- تنظيف snapshot عند رفض الطلبات حتى لا يعرض prompt قديم من طلب سابق.

### الملفات المعدلة
- `lib/app/data/services/app_settings_service.dart`
- `logixa_engine/src/runtime.rs`
- `did.md`

### خارج النطاق
- لا تغيير في Flutter UI.
- لا تغيير في Model Profiles.
- لا تغيير في طريقة تشغيل `llama-server`.
- لا تغيير في README أو todo.

### الفحوص المطلوبة
- `flutter analyze`
- `cd logixa_engine && cargo fmt && cargo check`
- إعادة تشغيل الـ Engine بعد تطبيق الفكس، ثم اختبار `/runtime/chat` والتأكد أن `system_prompt_applied=false` إذا كان `system_prompt` فارغًا.

### النتيجة المتوقعة
بعد مسح `system_prompt` وإعادة تشغيل الـ Engine:

```json
"system_prompt_applied": false,
"system_prompt_chars": 0,
"system_prompt_preview": null
```

## Step 23 Fix — Hidden System Prompt Hardening

### الهدف
إزالة أي System Prompt ثابت أو مخفي من إعدادات التشغيل، والتأكد أن الـ System Prompt لا يطبق إلا إذا حفظه المستخدم صراحة من الواجهة.

### ما تم تغييره
- إزالة default system prompt من Flutter settings service.
- تحديث Rust runtime بحيث لا يرسل role=system إذا كانت قيمة system_prompt فارغة.
- تصفير بيانات system_prompt في ردود runtime عند عدم وجود prompt فعلي.
- تحديث logixa_engine_config.example.json ليكون system_prompt فارغًا.
- تنظيف logixa_engine_config.json المحلي أثناء تطبيق السكريبت:
  - system_prompt = ""
  - إزالة {system_prompt} من prompt_template المحلي إن كان موجودًا داخل active_model_profile.

### الملفات المتغيرة
- lib/app/data/services/app_settings_service.dart
- logixa_engine/src/runtime.rs
- logixa_engine/logixa_engine_config.example.json
- did.md

### خارج النطاق
- لا تعديل README.md.
- لا تعديل todo.md.
- لا تغيير في موديل GGUF.
- لا تغيير في llama-server.
- لا إضافة System Prompt بديل.

### الاختبارات المطلوبة
- flutter analyze
- cd logixa_engine && cargo fmt && cargo check
- إيقاف أي process قديم على port 8787 ثم تشغيل cargo run من جديد.
- اختبار /runtime/chat والتأكد أن system_prompt_applied=false عندما يكون system_prompt فارغًا.

## Step 23 Fix — Hidden System Prompt Hardening

### الهدف
إزالة أي System Prompt ثابت أو مخفي من إعدادات التشغيل، والتأكد أن الـ System Prompt لا يطبق إلا إذا حفظه المستخدم صراحة من الواجهة.

### ما تم تغييره
- إزالة default system prompt من Flutter settings service.
- تحديث Rust runtime بحيث لا يرسل role=system إذا كانت قيمة system_prompt فارغة.
- تصفير بيانات system_prompt في ردود runtime عند عدم وجود prompt فعلي.
- تحديث logixa_engine_config.example.json ليكون system_prompt فارغًا.
- تنظيف logixa_engine_config.json المحلي أثناء تطبيق السكريبت:
  - system_prompt = ""
  - إزالة {system_prompt} من prompt_template المحلي إن كان موجودًا داخل active_model_profile.

### الملفات المتغيرة
- lib/app/data/services/app_settings_service.dart
- logixa_engine/src/runtime.rs
- logixa_engine/logixa_engine_config.example.json
- did.md

### خارج النطاق
- لا تعديل README.md.
- لا تعديل todo.md.
- لا تغيير في موديل GGUF.
- لا تغيير في llama-server.
- لا إضافة System Prompt بديل.

### الاختبارات المطلوبة
- flutter analyze
- cd logixa_engine && cargo fmt && cargo check
- إيقاف أي process قديم على port 8787 ثم تشغيل cargo run من جديد.
- اختبار /runtime/chat والتأكد أن system_prompt_applied=false عندما يكون system_prompt فارغًا.

## Step 23 Fix — Remove hidden Rust default system prompt

### الهدف
إزالة أي System Prompt ثابت/مخفي من مصدر إعدادات Rust وملفات JSON، بحيث لا يطبق المحرك أي System Prompt إلا إذا حفظه المستخدم صراحة من واجهة Flutter.

### ما تغير
- تفريغ مصدر الـ default system prompt في `logixa_engine/src/config.rs`.
- تفريغ `system_prompt` في `logixa_engine_config.example.json` و `logixa_engine_config.json`.
- تنظيف أي default قديم متبقٍ في `AppSettingsService` إن وجد.

### الاختبارات المطلوبة
- `flutter analyze`
- `cd logixa_engine && cargo fmt && cargo check`
- إيقاف أي Engine قديم على port 8787 ثم تشغيل `cargo run` من جديد.
- اختبار `/runtime/chat` والتأكد أن `system_prompt_applied=false` عندما يكون prompt فارغًا.


## Step 24 — Runtime Chat Response UX

### الهدف
تثبيت تجربة الشات بعد نجاح تشغيل GGUF الحقيقي عبر `llama-server`، بحيث تعرض الواجهة رد الموديل الفعلي بدل رسائل lifecycle القديمة، وتتعامل مع أخطاء Runtime بشكل واضح، وبدون أي System Prompt افتراضي أو مخفي.

### ما تم تنفيذه
- تحديث Parser الخاص بـ `/runtime/chat` داخل `EngineRuntimeChatResult` لقراءة الحقول الفعلية الجديدة:
  - `accepted`
  - `generated_text`
  - `model_started`
  - `model_stopped_after_response`
  - `model_loaded`
  - `server_url`
- جعل رسالة الشات تعرض `generated_text` مباشرة عند نجاح الاستجابة.
- جعل أخطاء Runtime تظهر كنص واضح بدل اعتبار `accepted=false` نجاحًا بسبب fallback قديم.
- إطالة timeout الخاص بطلب `/runtime/chat` فقط إلى 5 دقائق، لأن تحميل GGUF والتوليد المحلي قد يأخذ وقتًا أطول من طلبات status العادية.
- تحديث نصوص صفحة الشات لإزالة عبارات `lifecycle فقط` و `بدون GGUF` بعد نجاح Step 23.
- تحديث metadata المحادثة لتوضيح أن مصدر الرد هو `rust_llama_server_adapter`.

### الملفات المعدلة
- `lib/app/data/services/engine_client_service.dart`
- `lib/app/constants/app_strings.dart`
- `lib/app/modules/chat_page/controllers/chat_page_controller.dart`
- `did.md`

### ما لم يتم تنفيذه عمدًا
- لم يتم تعديل `README.md`.
- لم يتم تعديل `todo.md`.
- لم يتم إضافة Streaming.
- لم يتم إضافة UI جديد.
- لم يتم تغيير إعدادات الموديل تلقائيًا.
- لم يتم إضافة System Prompt افتراضي.
- لم يتم تعديل Rust Engine.

### أوامر الفحص المطلوبة
```bash
flutter analyze
flutter run -d linux
```

### اختبار يدوي مطلوب
1. شغّل Rust Engine بعد ضبط `LOGIXA_LLAMA_SERVER_BIN`.
2. افتح صفحة الشات.
3. أرسل رسالة قصيرة.
4. تأكد أن رسالة المساعد تعرض رد GGUF فقط، وليس نص `llama-server response completed`.
5. تأكد أن `system_prompt_applied=false` عندما لا يوجد System Prompt محفوظ.
6. جرّب إيقاف Engine وتأكد أن رسالة الخطأ تظهر بوضوح في الشات.

### الحالة
بانتظار فحص مصطفى ونتيجة `flutter analyze` قبل اعتماد Step 24.

---

## Step 24 Fix — System Prompt Text Input

### الهدف
إصلاح حقل السيستم برومبت في صفحة الإعدادات بعد اكتشاف أن الكتابة العربية لا تظهر داخل الحقل.

### سبب المشكلة
`ReusableSettingsTextField` كان يحدد الحقول الرقمية عن طريق `keyboardType.toString()` والبحث عن كلمة `decimal`.
هذا جعل `TextInputType.multiline` يُعامل كحقل رقمي لأن تمثيله النصي يحتوي على `decimal: null`، فتم تطبيق `FilteringTextInputFormatter` ومنع أي حروف عربية/إنجليزية.

### ما تغيّر
- تعديل `lib/app/widgets/reusable_widgets/reusable_settings_text_field.dart`.
- جعل الفلترة الرقمية تعمل فقط مع:
  - `TextInputType.number`
  - `TextInputType.numberWithOptions(decimal: true)`
- ترك `TextInputType.multiline` بدون input formatter.

### الملفات المتغيرة
- `lib/app/widgets/reusable_widgets/reusable_settings_text_field.dart`
- `did.md`

### الفحوصات المطلوبة
- `flutter analyze`
- `flutter run -d linux`
- تجربة كتابة سيستم برومبت عربي داخل الإعدادات.
- حفظ السيستم برومبت والتأكد أنه يظهر في رد `/runtime/chat` فقط عند حفظه يدويًا.

### ملاحظات
لا يوجد تعديل على Rust، ولا يوجد System Prompt افتراضي، ولا يوجد تغيير في تشغيل GGUF.


## Step 24 Fix — Chat Conversation Copy Export

### الهدف
إضافة إمكانية نسخ المحادثة الحالية بين المستخدم والموديل من واجهة الشات، حتى يمكن لصقها للمراجعة بدون فتح ملفات الذاكرة أو SQLite.

### ما تم
- إضافة زر `نسخ المحادثة` أعلى قائمة رسائل الشات.
- إضافة export نصي منظم يحتوي على رسائل المستخدم والمساعد وحالة runtime والبروفايل النشط.
- استبعاد رسالة الترحيب الافتراضية من النسخة المنسوخة.
- عدم نسخ محتوى System Prompt نفسه؛ يتم نسخ حالة وجوده وعدد حروفه فقط لتجنب تسريب نصوص غير مقصودة.
- استخدام Clipboard من Flutter بدون أي تغيير في Rust أو llama-server أو إعدادات الموديل.

### الملفات التي تغيّرت
- `lib/app/constants/app_strings.dart`
- `lib/app/modules/chat_page/controllers/chat_page_controller.dart`
- `lib/app/modules/chat_page/views/sections/chat_messages_section.dart`

### الفحوصات المطلوبة
- `flutter analyze`
- `flutter run -d linux`
- إرسال رسالتين في الشات ثم الضغط على `نسخ المحادثة` ولصق الناتج في أي محرر للتأكد من اكتماله.

### مؤجل
- تصدير المحادثة إلى ملف Markdown أو JSONL لاحقًا إذا احتجنا.

## Step 23 — Streaming Response

### الهدف
تنفيذ الخطوة الرسمية من `todo.md`: جعل رد الشات يظهر تدريجيًا بدل انتظار الرد الكامل.

### ما تغير
- إضافة Rust SSE endpoint:
  - `POST /runtime/chat/stream`
- إضافة endpoint لإيقاف التوليد:
  - `POST /runtime/stop-generation`
- استخدام `stream=true` عند الاتصال الداخلي بـ `llama-server` عبر OpenAI-compatible chat completions.
- استقبال Flutter للـ SSE tokens وتحديث رسالة المساعد تدريجيًا في الشات.
- إضافة زر إيقاف أثناء التوليد.
- حفظ الرسالة النهائية فقط في Rust Memory بعد اكتمال الرد بنجاح.

### الحدود
- لا يوجد WebSocket في هذه الخطوة.
- لا يوجد Model Router 4B/12B.
- لا يوجد Extensions work.
- لا يوجد System Prompt افتراضي أو مخفي.

### الاختبارات المطلوبة
- `flutter analyze`
- `cd logixa_engine && cargo fmt && cargo check`
- تشغيل Rust Engine مع `LOGIXA_LLAMA_SERVER_BIN` مضبوط.
- إرسال رسالة من الشات والتأكد أن الرد يظهر تدريجيًا.
- تجربة زر إيقاف أثناء التوليد.



## Step 23 Fix — Streaming Compile Issues

### الهدف
إصلاح أخطاء بناء Step 23 Streaming فقط بدون توسيع النطاق.

### ما تم
- إصلاح decoding في Flutter stream بحيث يتم تحويل `Stream<Uint8List>` إلى `Stream<List<int>>` قبل `utf8.decoder`.
- تفعيل feature `stream` في `reqwest` حتى يدعم `Response::bytes_stream()` داخل Rust runtime.

### الملفات المتغيرة
- `lib/app/data/services/engine_client_service.dart`
- `logixa_engine/Cargo.toml`
- `did.md`

### الفحوصات المطلوبة
- `flutter analyze`
- `cd logixa_engine && cargo check`

### ملاحظات
- لا يوجد تغيير في prompt defaults.
- لا يوجد تغيير في model router.
- لا يوجد تغيير في Extensions.

## Step 24 — Runtime Model Router 4B/12B: unblock selected model

### الهدف
بدء Step 24 الرسمية بإزالة المنع المؤقت الذي كان يمنع تحميل موديلات 12B، لأن اختيار الموديل يجب أن يكون من الـ active model profile الذي يحفظه المستخدم من Flutter، وليس من شرط ثابت داخل Rust.

### ما تم
- إزالة شرط `model_temporarily_blocked_12b_use_4b_first` من Runtime.
- حذف helper المؤقت `is_temporarily_blocked_12b_path` إن كان موجودًا.
- الحفاظ على قاعدة: Runtime لا يحمّل 4B و12B معًا؛ هو يشغل فقط الـ active model profile الحالي.
- الحفاظ على منع الـ hidden/default system prompt: `system_prompt_applied` يعتمد على وجود prompt فعلي غير فارغ.

### حدود الخطوة
- لا Auto Router حتى الآن.
- لا تحميل متوازي لموديلين.
- لا تغيير في Flutter UI.
- لا تغيير في prompt defaults.
- لا Streaming changes.

### الاختبارات المطلوبة
- `flutter analyze`
- `cd logixa_engine && cargo fmt && cargo check`
- اختيار موديل 4B وتشغيل رسالة قصيرة.
- اختيار موديل 12B absolute path وتجربة التشغيل مع مراقبة RAM/CPU؛ الفشل بسبب الذاكرة أو وقت التحميل يعتبر runtime/environment issue وليس block ثابت.

### الخطوة التالية
إكمال Step 24 Router UI/Policy عند الحاجة: Manual Fast/Quality selection واضح، ثم Auto Router لاحقًا فقط.


## Step 23 Fix — Streaming Compile Issues

### الهدف
إصلاح أخطاء بناء Step 23 Streaming فقط بدون توسيع النطاق.

### ما تم
- إصلاح decoding في Flutter stream بحيث يتم تحويل `Stream<Uint8List>` إلى `Stream<List<int>>` قبل `utf8.decoder`.
- تفعيل feature `stream` في `reqwest` حتى يدعم `Response::bytes_stream()` داخل Rust runtime.

### الملفات المتغيرة
- `lib/app/data/services/engine_client_service.dart`
- `logixa_engine/Cargo.toml`
- `did.md`

### الفحوصات المطلوبة
- `flutter analyze`
- `cd logixa_engine && cargo check`

### ملاحظات
- لا يوجد تغيير في prompt defaults.
- لا يوجد تغيير في model router.
- لا يوجد تغيير في Extensions.

## Step 24 Fix — Runtime streaming scope repair

### الهدف
إصلاح كسر Rust في `runtime.rs` بعد محاولات فك منع الموديل، حيث كانت دالة streaming تستخدم متغيرات خارج نطاقها مثل `stopped_after_response`, `model_started`, و`generated_text`.

### ما تم
- إعادة بناء منطق `run_chat_stream` بالكامل داخل النطاق الصحيح.
- توحيد validations الخاصة بالـ streaming مع `/runtime/chat`:
  - `local_model_enabled`
  - `auto_start_on_message`
  - prompt فارغ
  - model path مفقود
  - model path لازم يكون absolute
  - model file لازم يكون موجود
  - `llama-server` لازم يكون موجود أو مضبوط عبر `LOGIXA_LLAMA_SERVER_BIN`
- الحفاظ على `system_prompt_applied=false` عندما لا يوجد system prompt محفوظ.
- عدم إضافة أي system prompt افتراضي.
- عدم إعادة منع 12B؛ أي موديل يختاره المستخدم من Flutter هو مصدر التشغيل.

### الملفات المتغيرة
- `logixa_engine/src/runtime.rs`
- `did.md`

### الفحوصات المطلوبة
- `flutter analyze`
- `cd logixa_engine && cargo fmt && cargo check`

### التالي
بعد نجاح الفحص، يتم عمل commit للفكس فقط، ثم نكمل Step 24 الرسمية الخاصة بـ Runtime Model Router.
