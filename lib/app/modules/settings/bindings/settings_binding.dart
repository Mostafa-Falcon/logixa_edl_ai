import 'package:get/get.dart';

import '../../../widgets/app_core/controller/top_bar_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());

    if (!Get.isRegistered<TopBarController>()) {
      Get.lazyPut<TopBarController>(() => TopBarController(), fenix: true);
    }
  }
}
