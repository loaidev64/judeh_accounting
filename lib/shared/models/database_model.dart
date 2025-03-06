abstract class DatabaseModel {
  int id;

  DateTime createdAt;

  DateTime? updatedAt;

  DatabaseModel({
    this.id = 0,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> get toDatabase;
}
