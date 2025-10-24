import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/theme/theme_controller.dart';
import 'package:inventory_management/features/home/controller/admin_controller.dart';
import 'package:inventory_management/features/home/view/settings/users_list_screen.dart';
import 'package:inventory_management/features/auth/controller/login_controller.dart';
import 'package:inventory_management/features/auth/services/auth_local_data_source.dart';
import 'package:inventory_management/features/home/view/settings/change_password_screen.dart';
import 'package:inventory_management/features/user_controller.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final controller = Get.put(LoginController());
  final adminController = Get.put(AdminController());
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = controller.user.value;
    return ModalProgressHUD(
      inAsyncCall: controller.isLoading.value,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              title: Text(
                'Username: ${user?.username ?? 'N/A'}',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Email: ${user?.email ?? 'N/A'}',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: Text(
                'Role: ${user?.role ?? 'N/A'}',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: ListTile(
              title: Text(
                "Change Password",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: const Icon(Icons.lock),
              onTap: () => Get.to(() => ChangePasswordScreen()),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                title: Text(
                  'App Theme',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Switch(
                  value: Get.isDarkMode,
                  onChanged: (_) => Get.find<ThemeController>().toggleTheme(),
                  activeColor: Colors.red,
                  activeTrackColor: Colors.white,
                )),
          ),
          if (user?.role == 'Admin')
            Card(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: ListTile(
                title: Text(
                  'Update User Roles',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(Icons.edit),
                onTap: () {
                  Get.to(() => UserListScreen());
                },
              ),
            ),
          Card(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: ListTile(
              title: Text(
                'Logout',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: Icon(Icons.logout),
              onTap: () {
                Get.defaultDialog(
                  title: 'Logut',
                  middleText: 'Are you sure you want to logout?',
                  textConfirm: 'Yes',
                  textCancel: 'No',
                  buttonColor: Colors.red,
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.logout();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
