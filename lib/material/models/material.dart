import 'package:judeh_accounting/shared/models/database_model.dart';

class Material extends DatabaseModel {
  String name;
  double quantity;
  double cost;
  double price;
  String categoryId; // New field: categoryId (cannot be null)
  Unit unit;
  String? barcode; // New nullable field

  Material({
    super.id = '',
    required this.name,
    required this.quantity,
    required this.cost,
    required this.price,
    required this.categoryId, // Required field
    required this.unit, // Required field
    this.barcode, // New nullable field
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to create a [Material] object from a database map.
  factory Material.fromDatabase(Map<String, Object?> map) => Material(
        id: map['id'] as String,
        name: map['name'] as String,
        quantity: double.parse(map['quantity'].toString()),
        price: double.parse(map['price'].toString()),
        cost: double.parse(map['cost'].toString()),
        categoryId: map['category_id'] as String, // New field
        unit: Unit.values[map['unit'] as int],
        barcode: map['barcode'] as String?, // New nullable field
        createdAt: DateTime.parse(map['created'] as String),
        updatedAt: map['updated'] != null
            ? DateTime.parse(map['updated'] as String)
            : null,
      );

  /// Factory constructor to create an empty [Material] object.
  factory Material.empty() => Material(
        id: '',
        name: '',
        quantity: 0,
        cost: 0.0,
        price: 0.0,
        categoryId: '', // Default value for categoryId
        unit: Unit.amount,
        barcode: null, // Default value for barcode
        createdAt: DateTime.now(),
        updatedAt: null,
      );

  /// Converts the [Material] object to a map for database storage.
  @override
  Map<String, Object?> get toDatabase => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'cost': cost,
        'price': price,
        'category_id': categoryId, // New field
        'unit': unit.index,
        'barcode': barcode, // New nullable field

      };

  bool get isEmpty => id == 0;

  static const tableName = 'materials';
}

enum Unit {
  kilogram,
  // gram,
  // ton,
  amount;

  String get name => switch (this) {
        Unit.kilogram => 'كيلوغرام',
        // Unit.gram => 'غرام',
        // Unit.ton => 'طن',
        Unit.amount => 'قطعة',
      };
}
