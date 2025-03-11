import '../../models/database_model.dart';

class Category extends DatabaseModel {
  String name;
  String? description;
  CategoryType type;

  Category({
    super.id = 0,
    required this.name,
    this.description,
    required this.type,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Category] object from a database map.
  factory Category.fromDatabase(Map<String, Object?> map) => Category(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String?,
        type: CategoryType.values[map['type'] as int],
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Category] object.
  factory Category.empty(CategoryType type) => Category(
        id: 0,
        name: '',
        type: type,
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
        'type': type.index,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const tableName = 'categories';
}

enum CategoryType { material, expense }
