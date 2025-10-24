import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/app_colors.dart';
import 'package:inventory_management/core/util/app_text_styles.dart';

class PasswordTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final RxBool isPasswordHidden;
  final VoidCallback togglePasswordVisibility;
  final String hint;
  final String? Function(String?)? validator;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.isPasswordHidden,
    required this.togglePasswordVisibility,
    required this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 20.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() => TextFormField(
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onBackground),
              controller: controller,
              validator: validator,
              obscureText: isPasswordHidden.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).splashColor,
                hintText: hint,
                hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: !Get.isDarkMode
                        ? AppColors.primaryDark
                        : AppColors.primary,
                  ),
                  onPressed: togglePasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11.r),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11.r),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11.r),
                  borderSide: BorderSide(width: 1, color: AppColors.primary),
                ),
              ),
            )),
      ],
    );
  }
}
