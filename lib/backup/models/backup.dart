import 'package:judeh_accounting/shared/models/database_model.dart';
import 'dart:convert';

class Backup extends DatabaseModel {
  Map<String, dynamic> data;
  int modelId;
  BackupAction action; // Changed to enum
  String table;

  Backup({
    super.id = 0,
    required this.data,
    required this.modelId,
    required this.action,
    required this.table,
    super.createdAt,
    super.updatedAt,
  });

  factory Backup.fromDatabase(Map<String, Object?> map) => Backup(
        id: map['id'] as int,
        data: jsonDecode(map['data'] as String),
        modelId: map['model_id'] as int,
        action:
            BackupAction.values[map['action'] as int], // Convert index to enum
        table: map['_table'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );

  @override
  Map<String, Object?> get toDatabase => {
        'data': jsonEncode(data),
        'model_id': modelId,
        'action': action.index, // Store enum index
        '_table': table,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static const String tableName = '_backups';
}

enum BackupAction { create, update, delete }
