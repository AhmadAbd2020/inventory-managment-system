import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory_management/core/util/theme/theme_controller.dart';
import 'package:inventory_management/core/util/theme/themes.dart';
import 'package:inventory_management/features/auth/controller/login_controller.dart';

import 'package:inventory_management/features/auth/controller/sign_up_controller.dart';
import 'package:inventory_management/features/user_controller.dart';
import 'package:inventory_management/firebase_options.dart';
import 'package:inventory_management/inventory_app.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await Permission.storage.request();
  }

  await GetStorage.init();
  Get.put(UserController());
  Get.put(ThemeController());
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => kIsWeb
          ? Container(
              color: Colors.black,
              child: Center(
                child: SizedBox(
                  width: 430,
                  height: 932,
                  child: InventoryApp(),
                ),
              ),
            )
          : InventoryApp(),
    ),
  );
}
