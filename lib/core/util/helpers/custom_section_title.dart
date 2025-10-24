// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:inventory_management/core/util/app_colors.dart';
import 'package:inventory_management/core/util/app_text_styles.dart';

// ignore: must_be_immutable
class CustomSectionTitle extends StatelessWidget {
  final String title;
  Color titleColor;
  // ignore: use_key_in_widget_constructors
  CustomSectionTitle(
      {Key? key, required this.title, this.titleColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: AppTextStyles.boldTextStyle16.copyWith(color: titleColor));
  }
}
