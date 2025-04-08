// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:get/get.dart';
import 'package:judeh_accounting/material/models/material.dart';
import 'package:judeh_accounting/shared/extensions/double.dart';

import '../../shared/models/database_model.dart';

class OrderItem extends DatabaseModel {
  int materialId;
  String? materialName;
  Unit? materialUnit;
  double price;
  double quantity;
  int orderId;
  String? _description; // this field is if there is a quick material or service

  OrderItem({
    super.id = 0,
    required this.materialId,
    this.materialName,
    this.materialUnit,
    required this.price,
    required this.quantity,
    required this.orderId,
    String? description,
    super.createdAt,
    super.updatedAt,
  }) : _description = description;

  /// Factory constructor to create an [OrderItem] object from a database map.
  factory OrderItem.fromDatabase(Map<String, Object?> map) {
    Get.printInfo(info: map.toString());
    return OrderItem(
      id: map['id'] as int,
      materialId: map['material_id'] as int,
      materialName: map['material_name'] as String?,
      price: map['price'] as double,
      quantity: map['quantity'] as double,
      orderId: map['order_id'] as int,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Factory constructor to create an empty [OrderItem] object.
  factory OrderItem.empty() => OrderItem(
        id: 0,
        materialId: 0,
        price: 0.0,
        quantity: 0,
        orderId: 0,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

  /// Converts the [OrderItem] object to a map for database storage.
  @override
  Map<String, Object?> get toDatabase => {
        'id': id,
        'material_id': materialId,
        'price': price,
        'quantity': quantity,
        'order_id': orderId,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'order_items';

  double get subTotal => quantity * price;

  String get description =>
      _description ??
      '$materialName\n${price.toPriceString} X ${quantity.asIntIfItIsAnInt}';

  OrderItem copyWith({
    int? materialId,
    String? materialName,
    Unit? materialUnit,
    double? price,
    double? quantity,
    int? orderId,
    String? description,
  }) {
    return OrderItem(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      materialUnit: materialUnit ?? this.materialUnit,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      orderId: orderId ?? this.orderId,
      description: description ?? _description,
    );
  }

  OrderItem increaseQuantity({double by = 1}) =>
      copyWith(quantity: quantity + by);
}
