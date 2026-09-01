import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows a snackbar safely, ensuring it is scheduled post-frame to prevent
/// LateInitializationError when called during build cycles.
void showAppSnackbar(String title, String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: title.toLowerCase().contains('error') || message.toLowerCase().contains('error')
          ? Colors.red.shade800
          : Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  });
}
