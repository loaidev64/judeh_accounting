import 'package:judeh_accounting/shared/models/database_model.dart';

final class Customer extends DatabaseModel {
  String name;
  String? phoneNumber;
  String? description;

  Customer({
    super.id = 0,
    required this.name,
    this.phoneNumber,
    this.description,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Customer] object from a database map.
  factory Customer.fromDatabase(Map<String, Object?> map) => Customer(
        id: map['id'] as int,
        name: map['name'] as String,
        phoneNumber: map['phoneNumber'] as String?,
        description: map['description'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Customer] object.
  factory Customer.empty() => Customer(
        id: 0,
        name: '',
        phoneNumber: null,
        description: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

  /// Converts the [Customer] object to a map for database storage.
  @override
  Map<String, Object?> get toDatabase => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'customers';
}
