import 'package:get/get.dart';
import 'package:khetiq/features/authentication/controllers/auth_controller.dart';

class AppBindings {
  static void init() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
