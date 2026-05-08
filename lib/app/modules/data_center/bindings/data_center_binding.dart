import 'package:get/get.dart';

import '../controllers/data_center_controller.dart';

class DataCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataCenterController>(DataCenterController.new);
  }
}
