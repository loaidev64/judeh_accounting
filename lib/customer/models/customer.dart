import 'package:judeh_accounting/shared/models/database_model.dart';

class Customer extends DatabaseModel {
  String name;
  String? phoneNumber;
  String? description;

  Customer({
    super.id = '',
    required this.name,
    this.phoneNumber,
    this.description,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Customer] object from a database map.
  factory Customer.fromDatabase(Map<String, Object?> map) => Customer(
        id: map['id'] as String,
        name: map['name'] as String,
        phoneNumber: map['phoneNumber'] as String?,
        description: map['description'] as String?,
        createdAt: DateTime.parse(map['created'] as String),
        updatedAt: map['updated'] != null
            ? DateTime.parse(map['updated'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Customer] object.
  factory Customer.empty() => Customer(
        id: '',
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

      };

  static const tableName = 'customers';
}
