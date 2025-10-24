import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String itemId;
  final String siteId;
  final String type; // 'import' or 'export'
  final int quantity;
  final DateTime date;
  final String createdBy;
  final int balanceAfter;
  final int costPerUnit;
  String? siteName;
  TransactionModel({
    required this.id,
    required this.itemId,
    required this.siteId,
    required this.type,
    required this.quantity,
    required this.date,
    required this.createdBy,
    required this.balanceAfter,
    required this.costPerUnit,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
        id: id,
        itemId: data['itemId'],
        siteId: data['siteId'],
        type: data['type'],
        quantity: data['quantity'],
        date: (data['date'] as Timestamp).toDate(),
        createdBy: data['createdBy'],
        balanceAfter: data['balanceAfter'],
        costPerUnit: data['costPerUnit']);
  }
  TransactionModel copyWith(
      {String? id,
      String? itemId,
      String? siteId,
      String? type,
      int? quantity,
      DateTime? date,
      String? createdBy,
      int? balanceAfter,
      int? costPerUnit}) {
    return TransactionModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      siteId: siteId ?? this.siteId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      costPerUnit: costPerUnit ?? this.costPerUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'siteId': siteId,
      'type': type,
      'quantity': quantity,
      'date': date,
      'createdBy': createdBy,
      'balanceAfter': balanceAfter,
      'costPerUnit': costPerUnit,
    };
  }
}
