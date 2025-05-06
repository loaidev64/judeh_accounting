import 'package:judeh_accounting/order/models/order_item.dart';
import 'package:judeh_accounting/shared/models/database_model.dart';

class Order extends DatabaseModel {
  String? customerId;

  String? companyId;

  OrderType type;

  double total;

  double? debtAmount;

  String? companyName;

  String? customerName;

  final List<OrderItem> items;

  Order({
    super.id = '',
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
        id: map['id'] as String,
        customerId: map['customer_id'] as String?,
        companyId: map['company_id'] as String?,
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
        createdAt: DateTime.parse(map['created'] as String),
        updatedAt: map['updated'] != null
            ? DateTime.parse(map['updated'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Order] object.
  factory Order.empty(OrderType type) => Order(
        id: '',
        customerId: '',
        companyId: '',
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
    String? id,
    String? customerId,
    String? companyId,
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
