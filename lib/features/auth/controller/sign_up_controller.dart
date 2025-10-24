import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/features/auth/models/user_model.dart';
import 'package:inventory_management/features/auth/views/pages/new_user_screen.dart';
import 'package:inventory_management/features/auth/services/auth_local_data_source.dart';
import 'package:inventory_management/features/auth/services/auth_remote_data_source.dart';
import 'package:inventory_management/inventory_app.dart';

class SignUpController extends GetxController {
  RxBool isLoading = false.obs;
  var isPasswordHidden = true.obs;

  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  var isConfirmPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Invalid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password can't be empty";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> signUp() async {
    isLoading.value = true;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = usernameController.text.trim();
    final result =
        await AuthRemoteDataSourceImpl().signUp(name, email, password, 'Guest');
    isLoading.value = false;

    if (result != null) {
      SnackbarUtil.showSuccess('Success', "Account created successfully!");

      Get.offAll(() => NewUserScreen());
    } else {
      SnackbarUtil.showError('Error', "Failed to sign up. Try again.");
    }
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
