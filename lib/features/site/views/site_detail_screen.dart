import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/features/site/controller/site_details_controller.dart';
import 'package:inventory_management/features/site/models/site_model.dart';
import 'package:inventory_management/features/inventory/controller/transactions_controller.dart';
import 'package:sizer/sizer.dart';

class SiteDetailScreen extends StatelessWidget {
  final SiteModel site;

  const SiteDetailScreen({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    final SiteDetailController controller =
        Get.put(SiteDetailController(site.id));

    return Scaffold(
      appBar: AppBar(title: Text(site.name), actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'pdf') {
              controller.exportSiteTransactionsToPDF(site.id, site.name);
            } else if (value == 'excel') {
              controller.exportSiteTransactionsToExcel(site.id, site.name);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
            const PopupMenuItem(value: 'excel', child: Text('Export as Excel')),
          ],
        )
      ]),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Filter by Item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 16.w,
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: controller.selectedItemId.value.isEmpty
                          ? null
                          : controller.selectedItemId.value,
                      hint: const Text("Filter by Item"),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('All Items'),
                        ),
                        ...controller.itemQuantities.keys.map((itemId) {
                          final itemName = controller.transactionController
                                  .itemNameCache[itemId] ??
                              'Unknown';
                          return DropdownMenuItem<String>(
                            value: itemId,
                            child: Text(itemName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        controller.selectedItemId.value = value ?? '';
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '💰 Total Cost of All Items: ${NumberFormat('#,###').format(controller.totalSiteCost)}\$',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '📦 Item Quantities in This Site',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...controller.itemQuantities.entries.map((entry) {
              final itemId = entry.key;
              final itemName =
                  controller.transactionController.itemNameCache[itemId] ??
                      'Unknown Item';
              final totalQty = entry.value;

              final itemTxs = controller.filteredTransactions
                  .where((tx) => tx.itemId == itemId)
                  .toList();
              final totalCost = itemTxs.fold<int>(
                0,
                (sum, tx) => sum + (tx.costPerUnit * tx.quantity),
              );

              return ListTile(
                title: Text(
                  itemName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Total Cost: ${totalCost.toString()}\$',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  'Qty: $totalQty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '📅 Transactions by Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...controller.sortedDates.map((dateKey) {
              final txs = controller.groupedByDate[dateKey]!;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  title: Text(
                    'Date: $dateKey',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  children: txs.map((tx) {
                    final itemName = controller
                            .transactionController.itemNameCache[tx.itemId] ??
                        'Unknown Item';
                    final time = DateFormat.jm().format(tx.date);
                    return ListTile(
                      title: Text(
                        '$itemName - Qty: ${tx.quantity} - Cost Per Unit: ${tx.costPerUnit}\$ - Total Cost: ${tx.costPerUnit * tx.quantity}\$',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'By: ${tx.createdBy} at $time',
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
