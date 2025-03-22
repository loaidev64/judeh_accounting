import 'package:judeh_accounting/shared/models/database_model.dart';

final class Expense extends DatabaseModel {
  double cost;

  String? description;

  int categoryId;

  Expense({
    super.id = 0,
    required this.cost,
    this.description,
    required this.categoryId,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Expense] object from a database map.
  factory Expense.fromDatabase(Map<String, Object?> map) => Expense(
        id: map['id'] as int,
        description: map['description'] as String?,
        cost: map['cost'] as double,
        categoryId: map['category_id'] as int, // New field
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Expense] object.
  factory Expense.empty() => Expense(
        id: 0,
        description: null,
        cost: 0.0,
        categoryId: -1, // Default value for categoryId
        createdAt: DateTime.now(),
        updatedAt: null,
      );

  /// Converts the [Material] object to a map for database storage.
  @override
  Map<String, Object?> get toDatabase => {
        'id': id,
        'description': description,
        'cost': cost,
        'category_id': categoryId, // New field
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'expenses';
}
