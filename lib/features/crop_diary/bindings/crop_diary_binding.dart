import 'package:get/get.dart';
import 'package:khetiq/features/crop_diary/controllers/crop_diary_controller.dart';

class CropDiaryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CropDiaryController>()) {
      Get.lazyPut<CropDiaryController>(() => CropDiaryController());
    }
  }
}
