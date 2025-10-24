import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/circle_indicator.dart';
import 'package:inventory_management/core/util/helpers/custom_button.dart';
import 'package:inventory_management/core/util/helpers/normal_text_field.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';
import 'package:inventory_management/features/site/controller/add_site_controller.dart';
import 'package:inventory_management/features/site/controller/modify_site_controller.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddSiteScreen extends StatelessWidget {
  AddSiteScreen({super.key});
  final controller = Get.put(ModifySiteController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => ModalProgressHUD(
          inAsyncCall: controller.isLoading.value,
          progressIndicator: const CircleIndicator(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Add New Site',
              ),
            ),
            body: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    SizedBox(height: ScreenUtilNew.height(40)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: NormalTextField(
                        label: 'Site Name',
                        controller: controller.nameController,
                        hint: "Project A",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Site name can't be empty";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomButton(
                        text: 'Add Site',
                        onPressed: () async {
                          if (controller.formKey.currentState!.validate()) {
                            await controller.addSite();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: ScreenUtilNew.height(70)),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
