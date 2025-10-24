import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_management/core/util/app_colors.dart';
import 'package:inventory_management/core/util/app_text_styles.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';

// ignore: depend_on_referenced_packages

class CustomTextArea extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const CustomTextArea(
      {super.key,
      required this.label,
      required this.controller,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: AppTextStyles.textStyle15.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary)),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 20.sp)),
          ],
        ),
        SizedBox(height: ScreenUtilNew.height(8)),
        TextFormField(
          maxLines: 3,
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).splashColor,
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xff878787)),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
        ),
      ],
    );
  }
}
