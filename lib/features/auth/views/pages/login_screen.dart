import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/circle_indicator.dart';
import 'package:inventory_management/core/util/helpers/custom_button.dart';
import 'package:inventory_management/core/util/helpers/normal_text_field.dart';
import 'package:inventory_management/core/util/helpers/password_text_field.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';
import 'package:inventory_management/features/auth/controller/login_controller.dart';
import 'package:inventory_management/features/auth/controller/sign_up_controller.dart';
import 'package:inventory_management/features/auth/views/pages/reset_password_screen.dart';
import 'package:inventory_management/features/auth/views/pages/sign_up_screen.dart';
import 'package:inventory_management/features/auth/services/user_service.dart';
import 'package:inventory_management/features/auth/views/widgets/custom_auth_question.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final controller = Get.put(LoginController());

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
                        'Welcome Back',
                        style: textTheme.titleLarge?.copyWith(fontSize: 26.sp),
                      ),
                    ),
                    SizedBox(height: ScreenUtilNew.height(40)),
                    NormalTextField(
                      label: 'Email',
                      controller: controller.emailController,
                      hint: "ahmad@gmail.com",
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
                    SizedBox(height: ScreenUtilNew.height(24)),
                    Row(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              fillColor: WidgetStateProperty.all(Colors.red),
                              checkColor: Colors.white,
                              value: controller.rememberMe.value,
                              onChanged: (value) {
                                controller.rememberMe.value = value!;
                              },
                            ),
                            Text(
                              'Remember Me',
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const Spacer(flex: 1),
                        TextButton(
                          onPressed: () {
                            Get.offAll(() => ResetPasswordScreen(),
                                transition: Transition.rightToLeft);
                          },
                          child: Text(
                            'Forget Password?',
                            style: textTheme.bodyLarge?.copyWith(
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtilNew.height(24)),
                    CustomButton(
                      text: 'Login',
                      onPressed: () {
                        if (controller.formKey.currentState!.validate()) {
                          controller.signIn();
                        }
                      },
                    ),
                    SizedBox(height: ScreenUtilNew.height(24)),
                    CustomAuthQuestion(
                      textTheme: textTheme,
                      question: 'Don\'t have an account?',
                      buttonStr: 'Sign Up',
                      navigateFun: () {
                        Get.offAll(() => SignUpScreen());
                      },
                    ),
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
