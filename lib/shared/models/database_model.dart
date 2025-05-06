abstract class DatabaseModel {
  String id;

  DateTime createdAt;

  DateTime? updatedAt;

  DatabaseModel({
    this.id = '',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> get toDatabase;
}
