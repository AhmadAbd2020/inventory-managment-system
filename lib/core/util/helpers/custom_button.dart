import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory_management/core/util/app_colors.dart';
import 'package:inventory_management/core/util/app_text_styles.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
  });
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isOutlined
        ? Colors.transparent
        : isDarkMode
            ? AppColors.primaryDark // You can define this in AppColors
            : AppColors.primary;

    final borderColor = isDarkMode ? AppColors.primaryDark : AppColors.primary;

    final textColor = isOutlined ? borderColor : Colors.white;

    final iconColor = isOutlined ? borderColor : Colors.white;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: ScreenUtilNew.height(10)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: isOutlined ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextStyles.textStyle20.copyWith(
                color: textColor,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 10.w),
              Icon(
                icon,
                color: iconColor,
                size: 20.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
