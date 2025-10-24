import 'package:flutter/material.dart';

class CustomAuthQuestion extends StatelessWidget {
  const CustomAuthQuestion({
    super.key,
    required this.textTheme,
    required this.question,
    required this.buttonStr,
    required this.navigateFun,
  });

  final TextTheme textTheme;
  final String question;
  final String buttonStr;
  final void Function() navigateFun;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: textTheme.bodyLarge,
        ),
        TextButton(
          onPressed: navigateFun,
          child: Text(
            buttonStr,
            style: textTheme.bodyLarge
                ?.copyWith(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
