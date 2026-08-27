import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/farm_model.dart';
import '../services/farm_service.dart';

class FarmController extends GetxController {
  final FarmService _farmService = FarmService();

  final isLoading = false.obs;
  final farms = <FarmModel>[].obs;
  final selectedFarm = Rxn<FarmModel>();

  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  Future<bool> createFarm({
    required String name,
    required double area,
    required String areaUnit,
    required String village,
    required String district,
    required String state,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        Get.snackbar('Error', 'You are not logged in.');

        return false;
      }

      final farmId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();

      final farm = FarmModel(
        id: farmId,
        name: name.trim(),
        area: area,
        areaUnit: areaUnit,
        village: village.trim(),
        district: district.trim(),
        state: state.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _farmService.createFarm(uid: user.uid, farm: farm);

      farms.insert(0, farm);
      selectedFarm.value = farm;

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Unable to save your farm.');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFarms() async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        farms.clear();
        return;
      }

      final result = await _farmService.getFarms(user.uid);

      farms.assignAll(result);

      if (farms.isNotEmpty) {
        selectedFarm.value = farms.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Unable to load your farms.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFarm(String farmId) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return;
      }

      final farm = await _farmService.getFarm(uid: user.uid, farmId: farmId);

      selectedFarm.value = farm;
    } catch (e) {
      Get.snackbar('Error', 'Unable to load farm details.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateFarm({
    required String id,
    required String name,
    required double area,
    required String areaUnit,
    required String village,
    required String district,
    required String state,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return false;
      }

      final existingFarm = selectedFarm.value;

      if (existingFarm == null) {
        return false;
      }

      final farm = FarmModel(
        id: id,
        name: name.trim(),
        area: area,
        areaUnit: areaUnit,
        village: village.trim(),
        district: district.trim(),
        state: state.trim(),
        createdAt: existingFarm.createdAt,
        updatedAt: DateTime.now(),
      );

      await _farmService.updateFarm(uid: user.uid, farm: farm);

      final index = farms.indexWhere((item) => item.id == farm.id);

      if (index != -1) {
        farms[index] = farm;
      }

      selectedFarm.value = farm;

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Unable to update your farm.');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteFarm(String farmId) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return false;
      }

      await _farmService.deleteFarm(uid: user.uid, farmId: farmId);

      farms.removeWhere((farm) => farm.id == farmId);

      if (selectedFarm.value?.id == farmId) {
        selectedFarm.value = farms.isNotEmpty ? farms.first : null;
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Unable to delete your farm.');

      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
