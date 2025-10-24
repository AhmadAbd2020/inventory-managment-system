import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/custom_button.dart';
import 'package:inventory_management/core/util/helpers/password_text_field.dart';
import 'package:inventory_management/features/auth/controller/login_controller.dart';
import 'package:inventory_management/features/home/controller/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  final controller = Get.put(ChangePasswordController());

  final formKey = GlobalKey<FormState>();
  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16.h,
              children: [
                PasswordTextField(
                  label: 'Current Password',
                  controller: controller.oldPassword,
                  isPasswordHidden: controller.isOldPasswordHidden,
                  togglePasswordVisibility:
                      controller.toggleOldPasswordVisibility,
                  hint: 'Current Password',
                  validator: controller.validatePassword,
                ),
                PasswordTextField(
                  label: 'New Password',
                  controller: controller.newPassword,
                  isPasswordHidden: controller.isNewPasswordHidden,
                  togglePasswordVisibility:
                      controller.toggleNewPasswordVisibility,
                  hint: 'New Password',
                  validator: controller.validatePassword,
                ),
                PasswordTextField(
                  label: 'Confirm Password',
                  controller: controller.confirmPassword,
                  isPasswordHidden: controller.isConfirmPasswordHidden,
                  togglePasswordVisibility:
                      controller.toggleConfirmPasswordVisibility,
                  hint: 'Confirm Password',
                  validator: (value) {
                    if (value != controller.newPassword.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      controller.changePassword(controller.oldPassword.text,
                          controller.newPassword.text);
                    }
                  },
                  text: "Update Password",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
