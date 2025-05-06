import 'package:judeh_accounting/shared/models/database_model.dart';

class Debt extends DatabaseModel {
  String? customerId;
  String? companyId;
  String? orderId;
  double amount;

  Debt({
    super.id = '',
    this.customerId,
    this.companyId,
    this.orderId,
    required this.amount,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Debt] object from a database map.
  factory Debt.fromDatabase(Map<String, Object?> map) => Debt(
        id: map['id'] as String,
        customerId: map['customer_id'] as String?,
        companyId: map['company_id'] as String?,
        orderId: map['order_id'] as String?,
        amount: map['amount'] as double,
        createdAt: DateTime.parse(map['created'] as String),
        updatedAt: map['updated'] != null
            ? DateTime.parse(map['updated'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Debt] object.
  factory Debt.empty() => Debt(
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
