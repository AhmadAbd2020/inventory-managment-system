import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/circle_indicator.dart';
import 'package:inventory_management/core/util/helpers/custom_button.dart';
import 'package:inventory_management/core/util/helpers/normal_text_field.dart';
import 'package:inventory_management/core/util/helpers/password_text_field.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';
import 'package:inventory_management/features/auth/controller/sign_up_controller.dart';
import 'package:inventory_management/features/auth/views/pages/login_screen.dart';
import 'package:inventory_management/features/auth/views/widgets/custom_auth_question.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final controller = Get.put(SignUpController());

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
                        'Create an Account',
                        style: textTheme.titleLarge?.copyWith(fontSize: 26.sp),
                      ),
                    ),
                    SizedBox(height: ScreenUtilNew.height(40)),
                    NormalTextField(
                      label: 'Username',
                      controller: controller.usernameController,
                      hint: "JohnDoe",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Username can't be empty";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    NormalTextField(
                      label: 'Email',
                      controller: controller.emailController,
                      hint: "example@gmail.com",
                      validator: controller.validateEmail,
                    ),
                    SizedBox(height: 16.h),
                    PasswordTextField(
                      validator: controller.validatePassword,
                      label: 'Password',
                      controller: controller.passwordController,
                      isPasswordHidden: controller.isPasswordHidden,
                      togglePasswordVisibility:
                          controller.togglePasswordVisibility,
                      hint: '**********',
                    ),
                    SizedBox(height: 16.h),
                    PasswordTextField(
                      label: 'Confirm Password',
                      controller: controller.confirmPasswordController,
                      isPasswordHidden: controller.isConfirmPasswordHidden,
                      togglePasswordVisibility:
                          controller.toggleConfirmPasswordVisibility,
                      hint: '**********',
                      validator: (value) {
                        if (value != controller.passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: ScreenUtilNew.height(24)),
                    CustomButton(
                      text: 'Sign Up',
                      onPressed: () {
                        if (controller.formKey.currentState!.validate()) {
                          controller.signUp();
                        }
                      },
                    ),
                    SizedBox(height: ScreenUtilNew.height(24)),
                    CustomAuthQuestion(
                        textTheme: textTheme,
                        question: 'Already have an account?',
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
