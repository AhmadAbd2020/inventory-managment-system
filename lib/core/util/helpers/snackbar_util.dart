import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/app_colors.dart';

class SnackbarUtil {
  //success snackbar
  static void showSuccess(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // error snackbar
  static void showError(String title, String message) {
    _showSnackbar(
      title: title,
      message: message.replaceAll("Exception:", ""),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  //info snackbar
  static void showInfo(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color colorText,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: colorText,
      margin: EdgeInsets.all(16.w),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
      isDismissible: true,
    );
  }
}
