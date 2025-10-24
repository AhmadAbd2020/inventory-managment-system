import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/features/auth/models/user_model.dart';
import 'package:inventory_management/features/auth/views/pages/login_screen.dart';
import 'package:inventory_management/features/auth/views/pages/new_user_screen.dart';
import 'package:inventory_management/features/auth/services/auth_local_data_source.dart';
import 'package:inventory_management/features/auth/services/auth_remote_data_source.dart';
import 'package:inventory_management/features/home/controller/bottom_nav_controller.dart';
import 'package:inventory_management/features/home/view/home_page.dart';
import 'package:inventory_management/features/user_controller.dart';
import 'package:inventory_management/inventory_app.dart';

class LoginController extends GetxController {
  Rx<UserModel?> user = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var rememberMe = false.obs;

  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final AuthLocalDataSourceImpl _localDataSource = AuthLocalDataSourceImpl();
  final GetStorage storage = GetStorage();

  static const String rememberKey = 'remember_me';
  static const String rememberedEmailKey = 'remembered_email';
  static const String rememberedPasswordKey = 'remembered_password';

  @override
  void onInit() {
    super.onInit();

    final cached = _localDataSource.getCachedUser();
    if (cached != null) {
      user.value = cached;
    }
    _loadRememberedCredentials();
  }

  void _loadRememberedCredentials() {
    bool? remember = storage.read(rememberKey);
    if (remember != null && remember) {
      rememberMe.value = true;
      emailController.text = storage.read(rememberedEmailKey) ?? '';
      passwordController.text = storage.read(rememberedPasswordKey) ?? '';
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    isLoading.value = true;
    final result = await AuthRemoteDataSourceImpl().signIn(email, password);
    isLoading.value = false;

    if (result != null) {
      user.value = result;

      _localDataSource.cacheUser(user.value!);

      if (rememberMe.value) {
        storage.write(rememberKey, true);
        storage.write(rememberedEmailKey, email);
        storage.write(rememberedPasswordKey, password);
      } else {
        emailController.clear();
        passwordController.clear();
        storage.remove(rememberKey);
        storage.remove(rememberedEmailKey);
        storage.remove(rememberedPasswordKey);
      }
      SnackbarUtil.showSuccess('Success', "Logged in successfully!");

      if (user.value!.role == 'Guest') {
        Get.offAll(() => NewUserScreen());
      } else {
        Get.find<UserController>().loadUser();
        Get.offAll(() => HomePage());
      }
    } else {
      SnackbarUtil.showError('Error', "Invalid credentials. Try again.");
    }
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
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return "Password can't be empty";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> logout() async {
    isLoading.value = true;

    await _localDataSource.clearUser();
    await AuthRemoteDataSourceImpl().signOut();
    Get.find<BottomNavController>().resetIndex();
    user.value = null;
    isLoading.value = false;
    SnackbarUtil.showInfo('Logged Out', "Logout successfully!");

    Get.offAll(() => LoginScreen());
  }

  @override
  void onClose() {
    /*  emailController.dispose();
    passwordController.dispose(); */

    super.onClose();
  }
}
