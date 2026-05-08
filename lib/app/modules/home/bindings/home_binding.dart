import 'package:get/get.dart';

import '../../../widgets/app_core/controller/top_bar_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());

    if (!Get.isRegistered<TopBarController>()) {
      Get.lazyPut<TopBarController>(() => TopBarController(), fenix: true);
    }
  }
}
