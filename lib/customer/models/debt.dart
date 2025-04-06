import 'package:judeh_accounting/shared/models/database_model.dart';

class Debt extends DatabaseModel {
  int? customerId;
  int? companyId;
  int? orderId;
  double amount;

  Debt({
    super.id = 0,
    this.customerId,
    this.companyId,
    this.orderId,
    required this.amount,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Debt] object from a database map.
  factory Debt.fromDatabase(Map<String, Object?> map) => Debt(
        id: map['id'] as int,
        customerId: map['customer_id'] as int?,
        companyId: map['company_id'] as int?,
        orderId: map['order_id'] as int?,
        amount: map['amount'] as double,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Debt] object.
  factory Debt.empty() => Debt(
        id: 0,
        customerId: null,
        companyId: null,
        orderId: null,
        amount: 0,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

  /// Converts the [Debt] object to a map for database storage.
  @override
  Map<String, Object?> get toDatabase => {
        'id': id,
        'customer_id': customerId,
        'company_id': companyId,
        'order_id': orderId,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'debts';
}
