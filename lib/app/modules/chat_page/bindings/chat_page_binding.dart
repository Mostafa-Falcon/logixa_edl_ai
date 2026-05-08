import 'package:get/get.dart';

import '../../../widgets/app_core/controller/top_bar_controller.dart';
import '../controllers/chat_page_controller.dart';

class ChatPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatPageController());

    if (!Get.isRegistered<TopBarController>()) {
      Get.lazyPut<TopBarController>(() => TopBarController(), fenix: true);
    }
  }
}
