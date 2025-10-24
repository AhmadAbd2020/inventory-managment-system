import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory_management/features/inventory/controller/transactions_controller.dart';
import 'package:inventory_management/features/inventory/model/transaction_model.dart';

void showAddTransactionDialog(String itemId) async {
  final controller = Get.find<TransactionController>();
  final formKey = GlobalKey<FormState>();
  final quantityCtrl = TextEditingController();
  final costPerUnitCtrl = TextEditingController();
  final box = GetStorage();

  String selectedType = 'import';
  String? selectedSiteId;

  final sites = await controller.sites;

  showDialog(
    context: Get.context!,
    builder: (_) => AlertDialog(
      title: const Text('Add Transaction'),
      content: StatefulBuilder(
        builder: (context, setState) => Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['import', 'export']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedType = val ?? 'import';
                    selectedSiteId = null; // reset site when type changes
                  });
                },
              ),
              const SizedBox(height: 10),
              if (selectedType == 'export')
                DropdownButtonFormField<String>(
                  value: selectedSiteId,
                  items: sites
                      .map((site) => DropdownMenuItem(
                            value: site.id,
                            child: Text(site.name),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedSiteId = val),
                  decoration: const InputDecoration(labelText: "Site"),
                  validator: (val) => selectedType == 'export' && val == null
                      ? 'Select a site'
                      : null,
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: quantityCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter quantity' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: costPerUnitCtrl, // Text field for cost per unit
                decoration: const InputDecoration(labelText: 'Cost per Unit'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter cost per unit' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            final quantity = int.parse(quantityCtrl.text);
            final costPerUnit =
                int.parse(costPerUnitCtrl.text); // Parse cost per unit
            final createdBy = box.read('username') ?? 'Unknown';

            final tx = TransactionModel(
              id: '',
              itemId: itemId,
              siteId: selectedSiteId ?? '',
              type: selectedType,
              quantity: quantity,
              date: DateTime.now(),
              createdBy: createdBy,
              balanceAfter: 0,
              costPerUnit:
                  costPerUnit, // Set cost per unit in transaction model
            );

            await controller.addTransaction(tx);
            Get.back();
          },
          child: const Text('Save'),
        )
      ],
    ),
  );
}

void showEditTransactionDialog(TransactionModel oldTx) async {
  final controller = Get.find<TransactionController>();
  final formKey = GlobalKey<FormState>();
  final quantityCtrl = TextEditingController(text: oldTx.quantity.toString());
  final costPerUnitCtrl = TextEditingController(
      text: oldTx.costPerUnit.toString()); // Added controller for cost per unit

  String selectedType = oldTx.type;
  String? selectedSiteId = oldTx.siteId;
  final sites = await controller.sites;

  showDialog(
    context: Get.context!,
    builder: (_) => AlertDialog(
      title: const Text('Edit Transaction'),
      content: StatefulBuilder(
        builder: (context, setState) => Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['import', 'export']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedType = val ?? 'import';
                    if (selectedType == 'import') {
                      selectedSiteId = null; // reset site if not needed
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              if (selectedType == 'export')
                DropdownButtonFormField<String>(
                  value: selectedSiteId,
                  items: sites
                      .map((site) => DropdownMenuItem(
                            value: site.id,
                            child: Text(site.name),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedSiteId = val),
                  decoration: const InputDecoration(labelText: "Site"),
                  validator: (val) => selectedType == 'export' && val == null
                      ? 'Select a site'
                      : null,
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: quantityCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter quantity' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: costPerUnitCtrl, // Text field for cost per unit
                decoration: const InputDecoration(labelText: 'Cost per Unit'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter cost per unit' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            final newQuantity = int.parse(quantityCtrl.text);
            final newCostPerUnit =
                int.parse(costPerUnitCtrl.text); // Get new cost per unit
            final newTx = oldTx.copyWith(
              quantity: newQuantity,
              costPerUnit: newCostPerUnit, // Set new cost per unit
            );

            await controller.editTransaction(oldTx, newTx);
            Get.back();
          },
          child: const Text('Update'),
        )
      ],
    ),
  );
}

void showDeleteTransactionDialog(TransactionModel tx) {
  final controller = Get.find<TransactionController>();

  Get.defaultDialog(
    title: 'Delete Transaction',
    middleText: 'Are you sure you want to delete this transaction?',
    textConfirm: 'Yes',
    textCancel: 'No',
    confirmTextColor: Colors.white,
    onConfirm: () async {
      await controller.deleteTransaction(tx);
      Get.back();
    },
  );
}
