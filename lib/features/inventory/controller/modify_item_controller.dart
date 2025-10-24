import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:uuid/uuid.dart';

class ModifyItemController extends GetxController {
  final String itemId;
  final formKey = GlobalKey<FormState>();
  // TextEditingControllers
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final costController = TextEditingController();

  // Observing loading state
  final isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ModifyItemController({required this.itemId});

  @override
  void onInit() {
    super.onInit();
    _loadExistingItem();
  }

  Future<void> _loadExistingItem() async {
    final itemDoc = await _firestore.collection('items').doc(itemId).get();
    if (itemDoc.exists) {
      final itemData = itemDoc.data()!;
      nameController.text = itemData['name'];
      quantityController.text = itemData['quantity'].toString();
      costController.text = itemData['cost'].toString();
    } else {
      SnackbarUtil.showError('Error', "Item not found.");
    }
  }

  Future<void> uploadAndUpdateItem() async {
    final name = nameController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim());
    final cost = int.tryParse(costController.text.trim());

    if (name.isEmpty || quantity == null) {
      SnackbarUtil.showError('Error', "Please fill all fields.");

      return;
    }

    isLoading.value = true;

    try {
      print('object');
      await _firestore
          .collection('items')
          .doc(itemId)
          .update({'name': name, 'quantity': quantity, 'cost': cost});
      Get.showSnackbar(GetSnackBar());
      SnackbarUtil.showSuccess('Success', "Item updated successfully!");
      Get.back();
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to update item: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    quantityController.dispose();
    super.onClose();
  }
}
