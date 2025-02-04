import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trenord/controllers/main_screen_controller.dart';

class UIUtils {
  // Error message
  static void showError(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.red[50]!,
      textColor: Colors.red[900]!,
      icon: Icons.error_rounded,
      iconColor: Colors.red[900]!,
    );
  }

  // Success message
  static void showSuccess(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green[50]!,
      textColor: Colors.green[900]!,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green[900]!,
    );
  }

  // Warning message
  static void showWarning(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.orange[50]!,
      textColor: Colors.orange[900]!,
      icon: Icons.warning_rounded,
      iconColor: Colors.orange[900]!,
    );
  }

  // Info message
  static void showInfo(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.blue[50]!,
      textColor: Colors.blue[900]!,
      icon: Icons.info_rounded,
      iconColor: Colors.blue[900]!,
    );
  }


  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Container(
        margin: const EdgeInsets.only(left: 12, right: 12),
        child: Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
      ),
      shouldIconPulse: false,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration,
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }


  static void navigateToProfile() {
    // Navigate to main page
    Get.until((route) => route.isFirst);
    // Navigate to Profile page
    Get.find<MainScreenController>().changeTab(2);
  }
} 