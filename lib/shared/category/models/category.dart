import '../../models/database_model.dart';

class Category extends DatabaseModel {
  String name;
  String? description;
  CategoryType type;

  Category({
    super.id = '',
    required this.name,
    this.description,
    required this.type,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Category] object from a database map.
  factory Category.fromDatabase(Map<String, Object?> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        type: CategoryType.values[map['type'] as int],
        createdAt: DateTime.parse(map['created'] as String),
        updatedAt: map['updated'] != null
            ? DateTime.parse(map['updated'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Category] object.
  factory Category.empty(CategoryType type) => Category(
        id: '',
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

      };

  static const tableName = 'categories';
}

enum CategoryType { material, expense }
