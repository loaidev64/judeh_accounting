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
    name TEXT NOT NULL,
    description TEXT,
    createdAt TEXT NOT NULL,
    updatedAt TEXT
);
'''),
  Migration(tableName: Material.tableName, sql: '''
CREATE TABLE materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    cost REAL NOT NULL,
    price REAL NOT NULL,
    category_id INTEGER NOT NULL, -- New field: category_id (cannot be null)
    createdAt TEXT NOT NULL,
    updatedAt TEXT,
    FOREIGN KEY (category_id) REFERENCES categories(id) -- Optional foreign key constraint
);
''')
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
