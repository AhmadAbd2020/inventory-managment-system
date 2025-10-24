import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/features/auth/controller/login_controller.dart';
import 'package:inventory_management/features/site/models/site_model.dart';
import 'package:inventory_management/features/inventory/model/transaction_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class TransactionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxInt itemQuantity = 0.obs;
  RxString selectedTypeFilter = 'all'.obs;
  RxString selectedSiteFilter = ''.obs;

  @override
  void onInit() {
    listenToSiteChanges();
    super.onInit();
  }

  void resetFilters() {
    selectedTypeFilter.value = 'all';
    selectedSiteFilter.value = '';
  }

  Future<List<TransactionModel>> fetchSiteTransactions(String siteId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('siteId', isEqualTo: siteId)
        .where('type', isEqualTo: 'export')
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<TransactionModel>> listenToSiteTransactions(String siteId) {
    return _firestore
        .collection('transactions')
        .where('siteId', isEqualTo: siteId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  StreamSubscription? _transactionSubscription;
  StreamSubscription? _itemQuantitySubscription;

  String? _currentItemId;

  void listenToItemTransactions(String itemId) async {
    // Cancel previous listeners to avoid mixing data
    _transactionSubscription?.cancel();
    _itemQuantitySubscription?.cancel();

    _currentItemId = itemId;

    final siteMap = await _getSiteMap();

    _transactionSubscription = _firestore
        .collection('transactions')
        .where('itemId', isEqualTo: itemId)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      final txs = snapshot.docs.map((doc) {
        final data = doc.data();
        final tx = TransactionModel.fromMap(doc.id, data);
        tx.siteName = siteMap[tx.siteId] ?? 'Unknown Site';
        return tx;
      }).toList();

      // Only update if it's still the same item
      if (_currentItemId == itemId) {
        transactions.value = txs;
      }
    });

    _itemQuantitySubscription =
        _firestore.collection('items').doc(itemId).snapshots().listen((doc) {
      final data = doc.data();
      if (data != null &&
          data.containsKey('quantity') &&
          _currentItemId == itemId) {
        itemQuantity.value = data['quantity'];
      }
    });
  }

  Future<List<TransactionModel>> getItemTransactions(String itemId) async {
    final siteMap = await _getSiteMap();
    final snapshot = await _firestore
        .collection('transactions')
        .where('itemId', isEqualTo: itemId)
        .orderBy('date')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final tx = TransactionModel.fromMap(doc.id, data);
      tx.siteName = siteMap[tx.siteId] ?? 'Unknown Site';
      return tx;
    }).toList();
  }

  List<TransactionModel> get filteredTransactions {
    return transactions.where((tx) {
      if (selectedTypeFilter.value != 'all' &&
          tx.type != selectedTypeFilter.value) {
        return false;
      }

      if (selectedSiteFilter.value.isNotEmpty &&
          tx.siteName != selectedSiteFilter.value) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<Map<String, String>> _getSiteMap() async {
    final snapshot = await _firestore.collection('sites').get();
    return Map.fromEntries(snapshot.docs.map((doc) {
      return MapEntry(doc.id, doc['name']);
    }));
  }

  List<String> get siteNames {
    return transactions
        .where((tx) => tx.siteName != null && tx.siteName!.isNotEmpty)
        .map((tx) => tx.siteName!)
        .toSet()
        .toList();
  }

  Future<void> exportItemTransactionsToPDF(
      String itemId, String itemName) async {
    final pdf = pw.Document();
    final transactions = await getItemTransactions(itemId);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text("Transactions for $itemName",
                style: pw.TextStyle(fontSize: 24)),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Type', 'Qty', 'By', 'Date', 'Site', 'Balance'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerCellDecoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              border: pw.Border.all(
                color: PdfColors.black,
                width: 2,
              ),
            ),
            data: transactions
                .map((tx) => [
                      tx.type.toUpperCase(),
                      tx.quantity.toString(),
                      tx.createdBy,
                      DateFormat('yyyy-MM-dd – kk:mm').format(tx.date),
                      tx.siteName ?? 'N/A',
                      tx.balanceAfter.toString(),
                    ])
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final itemDoc = _firestore.collection('items').doc(transaction.itemId);
      final itemSnapshot = await itemDoc.get();
      final currentQuantity = itemSnapshot.data()?['quantity'] ?? 0;
      final itemData = itemSnapshot.data();
      // ❗ Check for insufficient stock before export
      if (transaction.type == 'export' &&
          transaction.quantity > currentQuantity) {
        Get.showSnackbar(const GetSnackBar(
          title: "Insufficient Stock",
        ));
        SnackbarUtil.showError(
            "Insufficient Stock", "Only $currentQuantity items available.");

        return; // 🚫 Prevent transaction
      }

      final balanceAfter = transaction.type == 'import'
          ? currentQuantity + transaction.quantity
          : currentQuantity - transaction.quantity;
      final int costPerUnit = transaction.costPerUnit != 0
          ? transaction.costPerUnit
          : (itemData?['cost'] ?? 0);
      final docRef = await _firestore.collection('transactions').add(
            transaction
                .copyWith(
                  balanceAfter: balanceAfter,
                  costPerUnit: costPerUnit,
                  date: DateTime.now(),
                  createdBy: Get.find<LoginController>().user.value?.username ??
                      'Un Known',
                )
                .toMap(),
          );

      // ✅ Update item quantity
      await itemDoc.update({'quantity': balanceAfter});
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to add transaction: $e");
    }
  }

  Map<String, String> itemNameCache = {};

  Future<String> getItemName(String itemId) async {
    if (itemNameCache.containsKey(itemId)) {
      return itemNameCache[itemId]!;
    }
    final doc = await _firestore.collection('items').doc(itemId).get();
    final name =
        doc.exists ? doc.data()!['name'] ?? 'Unknown Item' : 'Unknown Item';
    itemNameCache[itemId] = name;
    return name;
  }

  Future<void> preloadItemNames() async {
    final snapshot = await _firestore.collection('items').get();
    for (var doc in snapshot.docs) {
      itemNameCache[doc.id] = doc.data()['name'] ?? 'Unknown Item';
    }
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    try {
      final itemDoc = _firestore.collection('items').doc(transaction.itemId);
      final itemSnapshot = await itemDoc.get();
      final currentQuantity = itemSnapshot.data()?['quantity'] ?? 0;

      final newQuantity = transaction.type == 'import'
          ? currentQuantity - transaction.quantity
          : currentQuantity + transaction.quantity;

      await _firestore.collection('transactions').doc(transaction.id).delete();

      await itemDoc.update({'quantity': newQuantity});
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to delete transaction: $e");
    }
  }

  final RxList<SiteModel> sites = <SiteModel>[].obs;

  void listenToSiteChanges() {
    _firestore
        .collection('sites')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      sites.value = snapshot.docs
          .map((doc) => SiteModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> editTransaction(
      TransactionModel oldTx, TransactionModel newTx) async {
    try {
      final itemDoc = _firestore.collection('items').doc(oldTx.itemId);
      final itemSnapshot = await itemDoc.get();
      final currentQuantity = itemSnapshot.data()?['quantity'] ?? 0;

      // Revert old transaction to get the original state
      int revertedQuantity = oldTx.type == 'import'
          ? currentQuantity - oldTx.quantity
          : currentQuantity + oldTx.quantity;

      // ❗ Check for insufficient stock if new transaction is export
      if (newTx.type == 'export' && newTx.quantity > revertedQuantity) {
        Get.showSnackbar(const GetSnackBar(
          title: "Insufficient Stock",
        ));
        SnackbarUtil.showError(
            "Insufficient Stock", "Only $currentQuantity items available.");
        return;
      }

      int newBalance = newTx.type == 'import'
          ? revertedQuantity + newTx.quantity
          : revertedQuantity - newTx.quantity;

      await _firestore.collection('transactions').doc(oldTx.id).update(newTx
          .copyWith(
              date: DateTime.now(),
              createdBy: Get.find<LoginController>().user.value?.username ??
                  'Un Known',
              balanceAfter: newBalance,
              costPerUnit: newTx.costPerUnit != 0
                  ? newTx.costPerUnit
                  : (itemSnapshot.data()?['cost'] ?? 0))
          .toMap());

      await itemDoc.update({'quantity': newBalance});
    } catch (e) {
      SnackbarUtil.showError('Error', "Failed to edit transaction: $e");
    }
  }

  @override
  void onClose() {
    _transactionSubscription?.cancel();
    _itemQuantitySubscription?.cancel();
    super.onClose();
  }
}
