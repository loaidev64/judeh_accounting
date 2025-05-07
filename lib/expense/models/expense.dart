import 'package:judeh_accounting/shared/models/database_model.dart';

class Expense extends DatabaseModel {
  double cost;

  String? description;

  String categoryId;

  Expense({
    super.id = '',
    required this.cost,
    this.description,
    required this.categoryId,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Expense] object from a database map.
  factory Expense.fromDatabase(Map<String, Object?> map) => Expense(
        id: map['id'] as String,
        description: map['description'] as String?,
        cost: double.parse(map['cost'].toString()),
        categoryId: map['category_id'] as String, // New field
        createdAt: DateTime.parse(map['created'] as String),
        updatedAt: map['updated'] != null
            ? DateTime.parse(map['updated'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Expense] object.
  factory Expense.empty() => Expense(
        id: '',
        description: null,
        cost: 0.0,
        categoryId: '', // Default value for categoryId
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

      };

  static const tableName = 'expenses';
}
