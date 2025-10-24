import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/custom_button.dart';
import 'package:inventory_management/features/auth/views/pages/login_screen.dart';

class NewUserScreen extends StatelessWidget {
  const NewUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New User Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Wait until you verified by Admin'),
            SizedBox(height: 20),
            CustomButton(
              text: 'Back to Login Screen',
              onPressed: () {
                Get.offAll(() => LoginScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
