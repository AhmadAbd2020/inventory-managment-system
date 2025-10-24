import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:uuid/uuid.dart';

class AddItemController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final costController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final isLoading = false.obs;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  Future<void> uploadAndAddItem() async {
    final name = nameController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim());
    final cost = int.tryParse(costController.text.trim());

    if (name.isEmpty ||
        quantity == null ||
        selectedImage.value == null ||
        cost == null) {
      SnackbarUtil.showError(
          'Error', "Please fill all fields and select an image.");

      return;
    }

    isLoading.value = true;

    try {
      final file = selectedImage.value!;
      final fileName = const Uuid().v4();
      final ref = _storage.ref().child("item_images").child("$fileName.jpg");

      UploadTask uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _addOrUpdateItem(name, downloadUrl, quantity, cost);

      Get.back();
      SnackbarUtil.showSuccess('Success', "Item added/updated successfully!");
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to add item: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addOrUpdateItem(
      String name, String imageUrl, int newQuantity, int cost) async {
    final itemsRef = _firestore.collection('items');

    final existingItems = await itemsRef.where('name', isEqualTo: name).get();

    if (existingItems.docs.isNotEmpty) {
      final existingItem = existingItems.docs.first;
      final currentQuantity = existingItem['quantity'];
      await itemsRef.doc(existingItem.id).update({
        'quantity': currentQuantity + newQuantity,
      });
    } else {
      await itemsRef.add({
        'name': name,
        'picture': imageUrl,
        'quantity': newQuantity,
        'cost': cost
      });
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    quantityController.dispose();
    costController.dispose();
    super.onClose();
  }
}
