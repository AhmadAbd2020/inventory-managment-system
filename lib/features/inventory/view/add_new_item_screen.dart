import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/circle_indicator.dart';
import 'package:inventory_management/core/util/helpers/custom_button.dart';
import 'package:inventory_management/core/util/helpers/normal_text_field.dart';
import 'package:inventory_management/core/util/helpers/password_text_field.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';
import 'package:inventory_management/features/auth/controller/sign_up_controller.dart';
import 'package:inventory_management/features/auth/views/pages/login_screen.dart';
import 'package:inventory_management/features/inventory/controller/add_item_controller.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddItemScreen extends StatelessWidget {
  AddItemScreen({super.key});
  final controller = Get.put(AddItemController());
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Obx(() => ModalProgressHUD(
          inAsyncCall: controller.isLoading.value,
          progressIndicator: const CircleIndicator(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Add New Item to Inventory',
              ),
            ),
            body: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: ScreenUtilNew.height(40)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: NormalTextField(
                        label: 'Name',
                        controller: controller.nameController,
                        hint: "Cement Bag",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Name can't be empty";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: NormalTextField(
                        label: 'Cost per Unit',
                        controller: controller.costController,
                        hint: "10",
                        isNumeric: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Cost can't be empty";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: NormalTextField(
                        label: 'Quantity',
                        controller: controller.quantityController,
                        hint: "50",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Quantity can't be empty";
                          }
                          return null;
                        },
                        isNumeric: true,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(height: ScreenUtilNew.height(24)),
                    Obx(() {
                      return GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.w),
                          height: 160.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: controller.selectedImage.value != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        controller.selectedImage.value!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.white),
                                          onPressed: () {
                                            controller.selectedImage.value =
                                                null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_a_photo,
                                          size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text("Tap to select image",
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                        ),
                      );
                    }),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomButton(
                        text: 'Add Item',
                        onPressed: () async {
                          if (controller.formKey.currentState!.validate()) {
                            if (controller.selectedImage.value == null) {
                              SnackbarUtil.showError(
                                  'Error', "Please select an image");
                              return;
                            }
                            await controller.uploadAndAddItem();
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
