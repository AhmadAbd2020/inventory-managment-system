import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';
import 'package:inventory_management/core/util/theme/theme_controller.dart';
import 'package:inventory_management/core/util/theme/themes.dart';
import 'package:inventory_management/features/auth/models/user_model.dart';

import 'package:inventory_management/features/auth/controller/sign_up_controller.dart';
import 'package:inventory_management/features/auth/views/pages/login_screen.dart';
import 'package:inventory_management/features/auth/views/pages/new_user_screen.dart';
import 'package:inventory_management/features/auth/views/pages/reset_password_screen.dart';
import 'package:inventory_management/features/auth/views/pages/sign_up_screen.dart';
import 'package:inventory_management/features/auth/services/auth_local_data_source.dart';
import 'package:inventory_management/features/home/view/settings/users_list_screen.dart';
import 'package:inventory_management/features/home/view/home_page.dart';
import 'package:inventory_management/features/inventory/view/inventory_screen.dart';
import 'package:inventory_management/features/site/views/sites_screen.dart';
import 'package:sizer/sizer.dart';

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        ScreenUtilNew.init(context);
        return ScreenUtilInit(
          designSize: const Size(430, 932),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Inventory Management',
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: ThemeMode.system,
              home: LoginScreen(),
            );
          },
        );
      },
    );
  }
}
