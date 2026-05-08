import 'package:get/get.dart';

import '../../../widgets/app_core/controller/top_bar_controller.dart';
import '../controllers/work_space_controller.dart';

class WorkSpaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkSpaceController>(() => WorkSpaceController());

    if (!Get.isRegistered<TopBarController>()) {
      Get.lazyPut<TopBarController>(() => TopBarController(), fenix: true);
    }
  }
}
