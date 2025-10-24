import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/normal_text_field.dart';
import 'package:inventory_management/core/util/screen_util_new.dart';
import 'package:inventory_management/features/inventory/controller/modify_item_controller.dart';

class ModifyItemScreen extends StatelessWidget {
  final String itemId;

  const ModifyItemScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ModifyItemController(itemId: itemId));

    return Scaffold(
      appBar: AppBar(title: Text('Edit Item')),
      body: Obx(() {
        return Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: ScreenUtilNew.height(24)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NormalTextField(
                      label: 'Item Name',
                      controller: controller.nameController,
                      hint: 'Please enter a name'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NormalTextField(
                      label: 'Cost',
                      isNumeric: true,
                      controller: controller.costController,
                      hint: 'Please enter a cost'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NormalTextField(
                      label: 'Quantity',
                      isNumeric: true,
                      controller: controller.quantityController,
                      hint: 'Please enter a quantity'),
                ),
                controller.isLoading.value
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: controller.uploadAndUpdateItem,
                        child: Text('Save Changes'),
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
