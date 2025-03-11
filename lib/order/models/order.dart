import 'package:judeh_accounting/shared/models/database_model.dart';

final class Order extends DatabaseModel {
  int? customerId;

  int? companyId;

  OrderType type;

  Order({
    super.id = 0,
    this.customerId,
    this.companyId,
    required this.type,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Order] object from a database map.
  factory Order.fromDatabase(Map<String, Object?> map) => Order(
        id: map['id'] as int,
        customerId: map['customer_id'] as int?,
        companyId: map['company_id'] as int?,
        type: OrderType.values[map['type'] as int],
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Order] object.
  factory Order.empty(OrderType type) => Order(
        id: 0,
        customerId: 0,
        companyId: 0,
        type: type,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

  /// Converts the [Company] object to a map for database storage.
  @override
  Map<String, Object?> get toDatabase => {
        'id': id,
        'customer_id': customerId,
        'company_id': companyId,
        'type': type.index,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'orders';
}

enum OrderType { sell, sellRefund, buy, buyRefund }
