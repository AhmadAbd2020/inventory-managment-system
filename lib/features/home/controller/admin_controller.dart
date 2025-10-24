import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/features/auth/models/user_model.dart';
import 'package:inventory_management/features/home/view/settings/users_list_screen.dart';
import 'package:inventory_management/features/auth/services/user_service.dart';

class AdminController extends GetxController {
  final UserService _userService = UserService();
  final formKey = GlobalKey<FormState>();

  var users = <UserModel>[].obs;
  var isLoading = false.obs;
  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    users.value = await _userService.getUsers();
    isLoading.value = false;
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    bool success = await _userService.modifyUserRole(uid, newRole);
    if (success) {
      fetchUsers();
      SnackbarUtil.showSuccess('Success', "User role updated successfully!");
    } else {
      SnackbarUtil.showError('Error', "Failed to update role!");
    }
  }
}
