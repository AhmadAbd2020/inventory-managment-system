import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/features/inventory/model/transaction_model.dart';
import 'package:inventory_management/features/inventory/controller/transactions_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    // For Android 10 and below
    var legacyStatus = await Permission.storage.status;
    if (!legacyStatus.isGranted) {
      legacyStatus = await Permission.storage.request();
    }

    return status.isGranted || legacyStatus.isGranted;
  } else {
    return true;
  }
}

class SiteDetailController extends GetxController {
  final String siteId;
  final TransactionController transactionController = Get.find();

  RxBool isLoading = true.obs;
  RxString selectedItemId = ''.obs;
  RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;

  SiteDetailController(this.siteId);

  @override
  void onInit() {
    super.onInit();
    transactionController.preloadItemNames().then((_) {
      _listenToTransactions();
    });
  }

  Future<List<TransactionModel>> getSiteTransactions(String siteId) async {
    return await transactionController.fetchSiteTransactions(siteId);
  }

  Future<void> exportSiteTransactionsToExcel(
      String siteId, String siteName) async {
    if (!(await requestStoragePermission())) {
      SnackbarUtil.showError(
          'Permission Denied', 'Storage permission is required.');

      return;
    }

    try {
      final transactions = await getSiteTransactions(siteId);

      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      sheet.appendRow([
        TextCellValue('Item'),
        TextCellValue('Qty'),
        TextCellValue('Unit Cost'),
        TextCellValue('Total'),
        TextCellValue('By'),
        TextCellValue('Date'),
      ]);

      for (var tx in transactions) {
        sheet.appendRow([
          TextCellValue(
            transactionController.itemNameCache[tx.itemId] ?? 'Unknown',
          ),
          IntCellValue(tx.quantity),
          IntCellValue(tx.costPerUnit),
          IntCellValue(tx.costPerUnit * tx.quantity),
          TextCellValue(tx.createdBy),
          TextCellValue(DateFormat('yyyy-MM-dd – kk:mm').format(tx.date)),
        ]);
      }

      // 📂 Save to Downloads
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final safeFileName = siteName.replaceAll(RegExp(r'[^\w\s]+'), '');
      final filePath = "${downloadsDir.path}/$safeFileName-Transactions.xlsx";

      final fileBytes = excel.encode();
      final file = File(filePath);
      await file.writeAsBytes(fileBytes!);
      SnackbarUtil.showSuccess(
          '✅ Success', 'Excel file saved in Downloads:\n$filePath');
    } catch (e) {
      SnackbarUtil.showError('❌ Error', 'Failed to export Excel: $e');
    }
  }

  Future<Map<String, int>> getSiteItemBalances(String siteId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .doc(siteId)
        .collection('items')
        .get();

    return Map.fromEntries(snapshot.docs.map(
      (doc) => MapEntry(doc.id, doc.data()['remainingQuantity'] ?? 0),
    ));
  }

  Future<void> exportSiteTransactionsToPDF(
      String siteId, String siteName) async {
    final pdf = pw.Document();
    final transactions = await getSiteTransactions(siteId);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text(siteName,
                textAlign: pw.TextAlign.center,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Item Quantities in This Site',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Table.fromTextArray(
            headers: ['Item', 'Qyantity', 'Total Cost'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerCellDecoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
            ),
            data: itemQuantities.entries.map((entry) {
              final itemId = entry.key;
              final itemName =
                  transactionController.itemNameCache[itemId] ?? 'Unknown Item';
              final totalQty = entry.value;

              final itemTxs =
                  transactions.where((tx) => tx.itemId == itemId).toList();
              final totalCost = itemTxs.fold<int>(
                0,
                (sum, tx) => sum + (tx.costPerUnit * tx.quantity),
              );

              return [
                itemName,
                totalQty.toString(),
                '${totalCost.toString()}\$',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Transactions of This Site',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Table.fromTextArray(
            headers: ['Item', 'Qty', 'Unit Cost', 'Total', 'By', 'Date'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerCellDecoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(
                  color: PdfColors.black,
                  width: 2,
                )),
            data: transactions.map((tx) {
              return [
                transactionController.itemNameCache[tx.itemId] ?? 'Unknown',
                tx.quantity.toString(),
                '${tx.costPerUnit}\$',
                '${tx.costPerUnit * tx.quantity}\$',
                tx.createdBy,
                DateFormat('yyyy-MM-dd – kk:mm').format(tx.date),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  void _listenToTransactions() {
    transactionController.listenToSiteTransactions(siteId).listen((data) {
      allTransactions.value = data.where((tx) => tx.type == 'export').toList();
      isLoading.value = false;
    });
  }

  List<TransactionModel> get filteredTransactions {
    if (selectedItemId.value.isEmpty) return allTransactions;
    return allTransactions
        .where((tx) => tx.itemId == selectedItemId.value)
        .toList();
  }

  int get totalSiteCost => filteredTransactions.fold<int>(
      0, (sum, tx) => sum + (tx.costPerUnit * tx.quantity));

  Map<String, int> get itemQuantities {
    final Map<String, int> map = {};
    for (var tx in filteredTransactions) {
      map[tx.itemId] = (map[tx.itemId] ?? 0) + tx.quantity;
    }
    return map;
  }

  Map<String, List<TransactionModel>> get groupedByDate {
    final map = <String, List<TransactionModel>>{};
    for (var tx in filteredTransactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
      map.putIfAbsent(dateKey, () => []).add(tx);
    }
    return map;
  }

  List<String> get sortedDates {
    final keys = groupedByDate.keys.toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }
}
