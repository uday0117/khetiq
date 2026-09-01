import 'package:get/get.dart';
import '../controllers/crop_scan_controller.dart';

class CropScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CropScanController>(() => CropScanController(), fenix: true);
  }
}
