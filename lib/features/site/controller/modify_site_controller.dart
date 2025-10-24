import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/features/inventory/controller/transactions_controller.dart';
import 'package:inventory_management/features/site/models/site_model.dart';

class ModifySiteController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final isLoading = false.obs;
  final TransactionController transactionController =
      Get.find<TransactionController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ModifySiteController();

  Future<void> updateSite(String siteId) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      SnackbarUtil.showError('Error', "Site name cannot be empty.");

      return;
    }

    isLoading.value = true;
    try {
      await _firestore.collection('sites').doc(siteId).update({'name': name});
      await transactionController.sites;
      Get.back();

      SnackbarUtil.showSuccess('Success', "Site updated successfully!");
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to update site: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSite() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      SnackbarUtil.showError('Error', "Please enter a site name.");

      return;
    }

    isLoading.value = true;
    try {
      await _firestore.collection('sites').add({
        'name': name,
      });
      await transactionController.sites;
      Get.back();

      SnackbarUtil.showSuccess('Success', "Site added successfully!");
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to add site: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSite(String siteId) async {
    isLoading.value = true;
    try {
      await _firestore.collection('sites').doc(siteId).delete();
      await transactionController.sites;
      Get.back();

      SnackbarUtil.showSuccess('Deleted', "Site deleted successfully.");
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to delete site: $e");
    } finally {
      isLoading.value = false;
    }
  }

  confirmDeleteSite(String siteId) {
    Get.defaultDialog(
      title: 'Delete Item',
      middleText: 'Are you sure you want to delete this item?',
      textConfirm: 'Yes',
      onConfirm: () {
        deleteSite(siteId);
        Get.back();
      },
      textCancel: 'No',
      onCancel: () => Get.back(),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
