import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';

class UserProfileController extends GetxController {
  final UserProfileService _service = UserProfileService();

  final isLoading = false.obs;

  Future<bool> createProfile({
    required String name,
    required String phone,
    required String language,
  }) async {
    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar('Error', 'User is not logged in.');

        return false;
      }

      final profile = UserProfileModel(
        uid: user.uid,
        email: user.email ?? '',
        name: name.trim(),
        phone: phone.trim(),
        language: language,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.createProfile(profile);

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Unable to save your profile.');

      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
