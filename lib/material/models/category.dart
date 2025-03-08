import '../../shared/models/database_model.dart';

class Category extends DatabaseModel {
  String name;
  String? description;

  Category({
    super.id = 0,
    required this.name,
    this.description,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Category] object from a database map.
  factory Category.fromDatabase(Map<String, Object?> map) => Category(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Category] object.
  factory Category.empty() => Category(
        id: 0,
        name: '',
        description: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

  /// Converts the [Category] object to a map for database storage.
  @override
  Map<String, Object?> get toDatabase => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'categories';
}
