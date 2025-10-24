import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/circle_indicator.dart';
import 'package:inventory_management/core/util/helpers/custom_button.dart';
import 'package:inventory_management/core/util/helpers/normal_text_field.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';
import 'package:inventory_management/features/auth/controller/login_controller.dart';
import 'package:inventory_management/features/auth/controller/reset_password_controller.dart';
import 'package:inventory_management/features/auth/views/pages/login_screen.dart';
import 'package:inventory_management/features/auth/views/widgets/custom_auth_question.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});
  final controller = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Obx(
        () => ModalProgressHUD(
          inAsyncCall: controller.isLoading.value,
          progressIndicator: const CircleIndicator(),
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: ScreenUtilNew.height(110)),
                    Center(
                      child: Text(
                        'Reset Password',
                        style: textTheme.titleLarge?.copyWith(fontSize: 26.sp),
                      ),
                    ),
                    SizedBox(height: ScreenUtilNew.height(40)),
                    NormalTextField(
                      label: 'Email',
                      controller: controller.emailController,
                      hint: "mohamed@gmail.com",
                      validator: controller.validateEmail,
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(height: ScreenUtilNew.height(24)),
                    CustomButton(
                      text: 'Send Reset Email',
                      onPressed: () async {
                        if (controller.formKey.currentState!.validate()) {
                          await controller.sendPasswordResetEmail();
                        }
                      },
                    ),
                    SizedBox(height: ScreenUtilNew.height(24)),
                    CustomAuthQuestion(
                        textTheme: textTheme,
                        question: 'Remembered your password?',
                        buttonStr: 'Login',
                        navigateFun: () {
                          Get.offAll(() => LoginScreen());
                        }),
                    SizedBox(height: ScreenUtilNew.height(70)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
