import 'package:get/get.dart';

import '../controllers/farm_controller.dart';

class FarmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmController>(() => FarmController());
  }
}
