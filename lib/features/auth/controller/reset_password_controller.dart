import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/features/auth/views/pages/login_screen.dart';

class ResetPasswordController extends GetxController {
  var emailController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Invalid email';
    }
    return null;
  }

  Future<void> sendPasswordResetEmail() async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());

      SnackbarUtil.showSuccess(
          'Success', "Password reset email sent to ${emailController.text}");

      Get.offAll(() => LoginScreen());
    } on FirebaseAuthException catch (e) {
      SnackbarUtil.showError('Error', e.message ?? 'An error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
