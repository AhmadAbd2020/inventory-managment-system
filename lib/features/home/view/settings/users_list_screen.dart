import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/features/home/controller/admin_controller.dart';
import 'package:inventory_management/features/auth/models/user_model.dart';

class UserListScreen extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());

  UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("User Management"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return Center(child: Text("No users found."));
        }

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            UserModel user = controller.users[index];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 6.h),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: ListTile(
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  trailing: DropdownButton<String>(
                    value: user.role.contains(user.role) ? user.role : null,
                    items: ["Admin", "Guest", "Viewer", "Editor"]
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (newRole) {
                      if (newRole != null) {
                        controller.updateUserRole(user.uid, newRole);
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
