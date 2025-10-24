import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import '../model/item_model.dart';

enum SortOption { name, cost, quantity }

class ItemController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxList<ItemModel> filteredItems = <ItemModel>[].obs;
  final showLowStockOnly = false.obs;
  final selectedSort = SortOption.quantity.obs;
  var selectedImage = Rxn<File>();
  final searchQuery = ''.obs;
  @override
  void onInit() {
    super.onInit();
    listenToItemChanges();
  }

  void listenToItemChanges() {
    _firestore
        .collection('items')
        .orderBy('quantity', descending: false)
        .snapshots()
        .listen((snapshot) {
      items.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return ItemModel(
          id: doc.id,
          name: data['name'] ?? '',
          imageUrl: data['picture'] ?? '',
          quantity: data['quantity'] ?? 0,
          cost: data['cost'] ?? 0,
        );
      }).toList();
      applyFilters();
    });
  }

  void applySearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void toggleLowStockFilter(bool value) {
    showLowStockOnly.value = value;
    applyFilters();
  }

  void setSortOption(SortOption option) {
    selectedSort.value = option;
    applyFilters();
  }

  void applyFilters() {
    List<ItemModel> temp = items;

    // Filter by search
    if (searchQuery.value.isNotEmpty) {
      temp = temp
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // Filter by low stock
    if (showLowStockOnly.value) {
      temp = temp.where((item) => item.quantity < 100).toList();
    }

    // Sort based on selected option
    switch (selectedSort.value) {
      case SortOption.name:
        temp.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.cost:
        temp.sort((a, b) => b.cost.compareTo(a.cost));
        break;
      case SortOption.quantity:
        temp.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
    }

    filteredItems.value = temp;
  }

  confirmDeleteItem(String itemId) {
    Get.defaultDialog(
      title: 'Delete Item',
      middleText: 'Are you sure you want to delete this item?',
      textConfirm: 'Yes',
      onConfirm: () {
        deleteItem(itemId);
        Get.back();
      },
      textCancel: 'No',
      onCancel: () => Get.back(),
    );
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection('items').doc(itemId).delete();
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to delete item");
    }
  }

  Future<void> modifyItem(String itemId, String name, String imageUrl,
      int quantity, double cost) async {
    try {
      await _firestore.collection('items').doc(itemId).update({
        'name': name,
        'picture': imageUrl,
        'quantity': quantity,
        'cost': cost,
      });
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to modify item");
    }
  }
}
