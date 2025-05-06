import '../../shared/models/database_model.dart';

class Company extends DatabaseModel {
  String name;
  String? phoneNumber;
  String? description;

  Company({
    super.id = '',
    required this.name,
    this.phoneNumber,
    this.description,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Company] object from a database map.
  factory Company.fromDatabase(Map<String, Object?> map) => Company(
        id: map['id'] as String,
        name: map['name'] as String,
        phoneNumber: map['phoneNumber'] as String?,
        description: map['description'] as String?,
        createdAt: DateTime.parse(map['created'] as String),
        updatedAt: map['updated'] != null
            ? DateTime.parse(map['updated'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Company] object.
  factory Company.empty() => Company(
        id: '',
        name: '',
        phoneNumber: null,
        description: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

  /// Converts the [Company] object to a map for database storage.
  @override
  Map<String, Object?> get toDatabase => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'companies';

  bool get isEmpty => id == 0;
}
