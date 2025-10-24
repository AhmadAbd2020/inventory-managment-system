import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/features/inventory/controller/transactions_controller.dart';
import 'package:inventory_management/features/inventory/model/item_model.dart';
import 'package:inventory_management/features/inventory/view/transactions_dialog.dart';
import 'package:inventory_management/features/user_controller.dart';

class ItemDetailsScreen extends StatelessWidget {
  final ItemModel item;
  final controller = Get.put(TransactionController());
  final UserController userController = Get.find<UserController>();

  ItemDetailsScreen({super.key, required this.item}) {
    controller.resetFilters();
    controller.listenToItemTransactions(item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(item.name),
            SizedBox(
              width: 4,
            ),
            Obx(() => Text(
                  controller.itemQuantity.toString(),
                  style: TextStyle(fontSize: 12.sp),
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              controller.exportItemTransactionsToPDF(item.id, item.name);
            },
          ),
          if (userController.isAdmin || userController.isEditor)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showAddTransactionDialog(item.id);
              },
            )
        ],
      ),
      body: Obx(() {
        final transactions = controller.filteredTransactions;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Filters and Search
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: controller.selectedTypeFilter.value,
                    items: ['all', 'import', 'export']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.capitalizeFirst!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      controller.selectedTypeFilter.value = value!;
                    },
                  ),
                  Obx(() => DropdownButton<String>(
                        value: controller.selectedSiteFilter.value.isEmpty
                            ? null
                            : controller.selectedSiteFilter.value,
                        hint: const Text("Filter by Site"),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('All Sites'),
                          ),
                          ...controller.siteNames.map(
                            (site) => DropdownMenuItem(
                              value: site,
                              child: Text(site),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          controller.selectedSiteFilter.value = value ?? '';
                        },
                      )),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text("No transactions found."))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: tx.type == 'import'
                                    ? Colors.green
                                    : Colors.red,
                                child: Text(tx.type == 'import' ? 'I' : 'E'),
                              ),
                              title: Text(
                                  "${tx.type.toUpperCase()} — Qty: ${tx.quantity}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Date: ${DateFormat('yyyy-MM-dd').add_jm().format(tx.date)}"),
                                  Text("By: ${tx.createdBy}"),
                                  if (tx.type == 'export')
                                    Text("To Site: ${tx.siteName}"),
                                  Text("Balance After: ${tx.balanceAfter}"),
                                ],
                              ),
                              trailing: userController.isAdmin ||
                                      userController.isEditor
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.orange),
                                          onPressed: () =>
                                              showEditTransactionDialog(tx),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              showDeleteTransactionDialog(tx),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
