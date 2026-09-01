import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khetiq/core/utils/helpers.dart';
import '../models/crop_scan_result_model.dart';
import '../services/gemini_crop_scan_service.dart';

class CropScanController extends GetxController {
  final GeminiCropScanService _service = GeminiCropScanService();
  final ImagePicker _picker = ImagePicker();

  final selectedImage = Rxn<File>();
  final selectedCropCategory = 'Auto-detect'.obs;
  final userNotesController = TextEditingController();
  final customApiKeyController = TextEditingController();

  final isLoading = false.obs;
  final statusMessage = ''.obs;
  final scanResult = Rxn<CropScanResultModel>();

  final List<String> cropCategories = [
    'Auto-detect',
    'Tomato',
    'Potato',
    'Cotton',
    'Wheat',
    'Rice / Paddy',
    'Sugarcane',
    'Soybean',
    'Maize / Corn',
    'Chilli / Pepper',
    'Onion',
    'Grapes',
    'Banana',
    'Other / General',
  ];

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        scanResult.value = null; // Clear previous result on new image selection
      }
    } catch (e) {
      showAppSnackbar('Image Selection Error', 'Could not select image. Please try again.');
    }
  }

  void clearImage() {
    selectedImage.value = null;
    scanResult.value = null;
  }

  Future<bool> analyzeCrop() async {
    final imageFile = selectedImage.value;
    if (imageFile == null) {
      showAppSnackbar('Image Required', 'Please select or take a photo of the crop leaf/plant.');
      return false;
    }

    try {
      isLoading.value = true;
      statusMessage.value = 'Preparing image...';

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final String extension = imageFile.path.split('.').last.toLowerCase();
      final String mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';

      statusMessage.value = 'Analyzing plant symptoms with Gemini AI...';

      final result = await _service.analyzeCropImage(
        imageBytes: imageBytes,
        mimeType: mimeType,
        cropCategory: selectedCropCategory.value,
        userNotes: userNotesController.text,
        customApiKey: customApiKeyController.text,
        localImagePath: imageFile.path,
      );

      scanResult.value = result;

      // Save history if user logged in
      final user = currentUser;
      if (user != null) {
        _service.saveScanHistory(uid: user.uid, scanResult: result);
      }

      return true;
    } catch (e) {
      final errorStr = e.toString().replaceAll('Exception: ', '');
      showAppSnackbar('Crop Scan Failed', errorStr);
      return false;
    } finally {
      isLoading.value = false;
      statusMessage.value = '';
    }
  }

  @override
  void onClose() {
    userNotesController.dispose();
    customApiKeyController.dispose();
    super.onClose();
  }
}
