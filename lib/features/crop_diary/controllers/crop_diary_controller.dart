import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/diary_entry_model.dart';
import '../services/crop_diary_service.dart';

class CropDiaryController extends GetxController {
  final CropDiaryService _diaryService = CropDiaryService();

  final isLoading = false.obs;

  final entries = <DiaryEntryModel>[].obs;

  final selectedEntry = Rxn<DiaryEntryModel>();

  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  // CREATE
  Future<bool> createEntry({
    required String farmId,
    required String cropId,
    required String title,
    required String description,
    required String type,
    required DateTime date,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        Get.snackbar(
          'Error',
          'You are not logged in.',
        );
        return false;
      }

      final now = DateTime.now();

      final entry = DiaryEntryModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        cropId: cropId,
        title: title.trim(),
        description: description.trim(),
        type: type,
        date: date,
        createdAt: now,
        updatedAt: now,
      );

      await _diaryService.createEntry(
        uid: user.uid,
        farmId: farmId,
        cropId: cropId,
        entry: entry,
      );

      entries.insert(0, entry);
      selectedEntry.value = entry;

      Get.snackbar(
        'Success',
        'Diary entry added successfully.',
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to save diary entry.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // READ - ALL
  Future<void> loadEntries({
    required String farmId,
    required String cropId,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        entries.clear();
        return;
      }

      final result = await _diaryService.getEntries(
        uid: user.uid,
        farmId: farmId,
        cropId: cropId,
      );

      entries.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to load diary entries.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // READ - SINGLE
  Future<void> loadEntry({
    required String farmId,
    required String cropId,
    required String entryId,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        selectedEntry.value = null;
        return;
      }

      final entry = await _diaryService.getEntry(
        uid: user.uid,
        farmId: farmId,
        cropId: cropId,
        entryId: entryId,
      );

      selectedEntry.value = entry;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to load diary entry.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // UPDATE
  Future<bool> updateEntry({
    required String farmId,
    required String cropId,
    required String entryId,
    required String title,
    required String description,
    required String type,
    required DateTime date,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return false;
      }

      final existingEntry = selectedEntry.value;

      if (existingEntry == null) {
        return false;
      }

      final updatedEntry = DiaryEntryModel(
        id: entryId,
        cropId: cropId,
        title: title.trim(),
        description: description.trim(),
        type: type,
        date: date,
        createdAt: existingEntry.createdAt,
        updatedAt: DateTime.now(),
      );

      await _diaryService.updateEntry(
        uid: user.uid,
        farmId: farmId,
        cropId: cropId,
        entry: updatedEntry,
      );

      final index = entries.indexWhere(
        (entry) => entry.id == entryId,
      );

      if (index != -1) {
        entries[index] = updatedEntry;
      }

      selectedEntry.value = updatedEntry;

      Get.snackbar(
        'Success',
        'Diary entry updated successfully.',
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to update diary entry.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // DELETE
  Future<bool> deleteEntry({
    required String farmId,
    required String cropId,
    required String entryId,
  }) async {
    try {
      isLoading.value = true;

      final user = currentUser;

      if (user == null) {
        return false;
      }

      await _diaryService.deleteEntry(
        uid: user.uid,
        farmId: farmId,
        cropId: cropId,
        entryId: entryId,
      );

      entries.removeWhere(
        (entry) => entry.id == entryId,
      );

      if (selectedEntry.value?.id == entryId) {
        selectedEntry.value = null;
      }

      Get.snackbar(
        'Success',
        'Diary entry deleted successfully.',
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to delete diary entry.',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearSelectedEntry() {
    selectedEntry.value = null;
  }
}