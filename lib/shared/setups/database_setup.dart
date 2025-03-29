part of 'setup.dart';

const _migrations = <Migration>[
  Migration(tableName: Company.tableName, sql: '''
  CREATE TABLE companies (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL,
    phoneNumber TEXT,
    description TEXT,
    createdAt TEXT NOT NULL,
    updatedAt TEXT
);
'''),
  Migration(tableName: Category.tableName, sql: '''
  CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL UNIQUE,  // Added UNIQUE constraint
    description TEXT,
    type INTEGER,
    createdAt TEXT NOT NULL,
    updatedAt TEXT
);
'''),
  Migration(tableName: Material.tableName, sql: '''
CREATE TABLE materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL,
    quantity REAL NOT NULL,
    cost REAL NOT NULL,
    price REAL NOT NULL,
    category_id INTEGER NOT NULL, -- New field: category_id (cannot be null)
    unit INTEGER NOT NULL,
    barcode TEXT, -- New nullable field
    createdAt TEXT NOT NULL,
    updatedAt TEXT,
    FOREIGN KEY (category_id) REFERENCES categories(id) -- Optional foreign key constraint
);
'''),
  Migration(tableName: Expense.tableName, sql: '''
CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      cost REAL NOT NULL,
      description TEXT,
      category_id INTEGER NOT NULL,
      createdAt TEXT NOT NULL,
      updatedAt TEXT,
      FOREIGN KEY (category_id) REFERENCES categories(id)
    );
'''),
  Migration(tableName: Customer.tableName, sql: '''
  CREATE TABLE customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL,
    phoneNumber TEXT,
    description TEXT,
    createdAt TEXT NOT NULL,
    updatedAt TEXT
);
'''),
  Migration(tableName: Order.tableName, sql: '''
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    customer_id INTEGER,
    company_id INTEGER,
    type INTEGER NOT NULL,
    total REAL NOT NULL,
    createdAt TEXT NOT NULL,
    updatedAt TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (company_id) REFERENCES companies(id)
);
'''),
  Migration(tableName: OrderItem.tableName, sql: '''
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    material_id INTEGER NOT NULL,
    price REAL NOT NULL,
    quantity REAL NOT NULL,
    order_id INTEGER NOT NULL,
    createdAt TEXT NOT NULL,
    updatedAt TEXT,
    FOREIGN KEY (material_id) REFERENCES materials(id),
    FOREIGN KEY (order_id) REFERENCES orders(id)
);
'''),
  Migration(tableName: Debt.tableName, sql: '''
CREATE TABLE debts (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    customer_id INTEGER,
    company_id INTEGER,
    order_id INTEGER,
    amount REAL NOT NULL,
    createdAt TEXT NOT NULL,
    updatedAt TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (company_id) REFERENCES companies(id)
);
'''),
  Migration(tableName: Backup.tableName, sql: '''
CREATE TABLE _backups (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    data TEXT NOT NULL,
    model_id INTEGER NOT NULL,
    action INTEGER NOT NULL,
    _table TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    updatedAt TEXT
);
'''),
];

Future<void> _setupDatabase() async {
  final databasesPath = await getDatabasesPath();
  final path = '$databasesPath/database.db';
  final database = await openDatabase(
    path,
    version: 1,
    onCreate: _runMigrations,
  );
  Get.put(database, permanent: true);
}

void _runMigrations(Database db, int version) async {
  for (final migration in _migrations) {
    Get.printInfo(
        info: 'creating ${migration.tableName} table: ${migration.sql}');
    await db.execute(migration.sql);
  }
}
