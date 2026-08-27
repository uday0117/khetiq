import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/crop_model.dart';
import '../services/crop_planner_service.dart';

class CropPlannerController extends GetxController {
  final CropPlannerService _service = CropPlannerService();

  final isLoading = false.obs;

  final crops = <CropModel>[].obs;

  final selectedCrop = Rxn<CropModel>();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> loadCrops(String farmId) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        crops.clear();
        return;
      }

      final result = await _service.getCrops(uid: user.uid, farmId: farmId);

      crops.assignAll(result);

      if (crops.isEmpty) {
        selectedCrop.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Unable to load crops.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createCrop({
    required String farmId,
    required String cropName,
    required String season,
    required double area,
    required String areaUnit,
    DateTime? plannedDate,
    DateTime? plantingDate,
    String? variety,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return false;
      }

      final now = DateTime.now();

      final crop = CropModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmId: farmId,
        cropName: cropName.trim(),
        season: season,
        area: area,
        areaUnit: areaUnit,
        plannedDate: plannedDate,
        plantingDate: plantingDate,
        variety: variety?.trim(),
        notes: notes?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _service.createCrop(uid: user.uid, crop: crop);

      crops.insert(0, crop);

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Unable to add crop.');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCrop({
    required String farmId,
    required String cropId,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return;
      }

      selectedCrop.value = await _service.getCrop(
        uid: user.uid,
        farmId: farmId,
        cropId: cropId,
      );
    } catch (e) {
      Get.snackbar('Error', 'Unable to load crop.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCrop({
    required String farmId,
    required String cropId,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return false;
      }

      await _service.deleteCrop(uid: user.uid, farmId: farmId, cropId: cropId);

      crops.removeWhere((crop) => crop.id == cropId);

      if (selectedCrop.value?.id == cropId) {
        selectedCrop.value = null;
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Unable to delete crop.');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCrop({required CropModel crop}) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return false;
      }

      final updatedCrop = CropModel(
        id: crop.id,
        farmId: crop.farmId,
        cropName: crop.cropName.trim(),
        season: crop.season,
        area: crop.area,
        areaUnit: crop.areaUnit,
        plannedDate: crop.plannedDate,
        plantingDate: crop.plantingDate,
        variety: crop.variety?.trim(),
        notes: crop.notes?.trim(),
        createdAt: crop.createdAt,
        updatedAt: DateTime.now(),
      );

      await _service.updateCrop(uid: user.uid, crop: updatedCrop);

      final index = crops.indexWhere((item) => item.id == crop.id);

      if (index != -1) {
        crops[index] = updatedCrop;
      }

      selectedCrop.value = updatedCrop;

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Unable to update crop.');

      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
