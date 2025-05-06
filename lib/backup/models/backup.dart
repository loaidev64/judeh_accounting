import 'package:judeh_accounting/shared/models/database_model.dart';
import 'dart:convert';

class Backup extends DatabaseModel {
  Map<String, dynamic> data;
  String modelId;
  BackupAction action; // Changed to enum
  String table;

  Backup({
    super.id = '',
    required this.data,
    required this.modelId,
    required this.action,
    required this.table,
    super.createdAt,
    super.updatedAt,
  });

  factory Backup.fromDatabase(Map<String, Object?> map) => Backup(
        id: map['id'] as String,
        data: jsonDecode(map['data'] as String),
        modelId: map['model_id'] as String,
        action:
            BackupAction.values[map['action'] as int], // Convert index to enum
        table: map['_table'] as String,
        createdAt: DateTime.parse(map['created'] as String),
        updatedAt: map['updated'] != null
            ? DateTime.parse(map['updated'] as String)
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
