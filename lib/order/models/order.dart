import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/shared/models/database_model.dart';

class Order extends DatabaseModel {
  int? customerId;

  int? companyId;

  OrderType type;

  double total;

  double? debtAmount;

  String? companyName;

  String? customerName;

  final List<OrderItem> items;

  Order({
    super.id = 0,
    this.customerId,
    this.companyId,
    this.customerName,
    this.companyName,
    required this.type,
    required this.total,
    required this.items,
    this.debtAmount,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Order] object from a database map.
  factory Order.fromDatabase(Map<String, Object?> map) => Order(
        id: map['id'] as int,
        customerId: map['customer_id'] as int?,
        companyId: map['company_id'] as int?,
        customerName: map['customer_name'] as String?,
        companyName: map['company_name'] as String?,
        type: OrderType.values[map['type'] as int],
        total: map['total'] as double,
        items: map['order_items'] != null
            ? (map['order_items'] as List)
                .map((e) => OrderItem.fromDatabase(e))
                .toList()
            : [],
        debtAmount: map['debt_amount'] as double?,
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
        total: 0,
        items: [],
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
        'total': total,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'orders';

  Order copyWith({
    int? id,
    int? customerId,
    int? companyId,
    String? customerName,
    String? companyName,
    OrderType? type,
    double? total,
    double? debtAmount,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Order(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        companyId: companyId ?? this.companyId,
        customerName: customerName ?? this.customerName,
        companyName: companyName ?? this.companyName,
        type: type ?? this.type,
        total: total ?? this.total,
        items: items ?? this.items,
        debtAmount: debtAmount ?? this.debtAmount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

enum OrderType {
  sell,
  sellRefund,
  buy,
  buyRefund;

  bool get canHaveCustomer =>
      this == OrderType.sell || this == OrderType.sellRefund;
}
