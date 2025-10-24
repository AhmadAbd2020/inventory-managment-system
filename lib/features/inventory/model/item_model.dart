import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String name;
  final String imageUrl;
  final int quantity;
  final int cost;
  ItemModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.cost,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['picture'] ?? '',
      quantity: map['quantity'] ?? 0,
      cost: (map['cost'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'picture': imageUrl,
      'quantity': quantity,
      'cost': cost,
    };
  }
}
