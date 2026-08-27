import 'package:get/get.dart';

import '../controllers/crop_planner_controller.dart';

class CropPlannerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CropPlannerController>()) {
      Get.lazyPut<CropPlannerController>(() => CropPlannerController());
    }
  }
}
