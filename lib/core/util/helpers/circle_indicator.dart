import 'package:flutter/material.dart';
import 'package:inventory_management/core/util/app_colors.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';

class CircleIndicator extends StatelessWidget {
  const CircleIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtilNew.height(400)),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
