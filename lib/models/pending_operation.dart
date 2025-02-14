import 'dart:convert';

import 'package:alkhal/models/model.dart';

class PendingOperation extends Model {
  static const String tableName = "pending_operations";

  final String operation;
  final String tName;
  final int recordId;
  final Map data;
  final int timestamp;
  final String uuid;

  PendingOperation({
    super.id,
    required this.operation,
    required this.tName,
    required this.recordId,
    required this.data,
    required this.timestamp,
    required this.uuid,
  });
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      "operation": operation,
      'table_name': tName,
      'record_id': recordId,
      'data': data,
      'timestamp': timestamp,
      'uuid': uuid,
    };
  }

  factory PendingOperation.fromMap(Map<String, dynamic> map) {
    return PendingOperation(
      id: map['id'],
      operation: map['operation'],
      tName: map['table_name'],
      recordId: map['record_id'],
      data: jsonDecode(map['data']),
      timestamp: map['timestamp'],
      uuid: map['uuid'],
    );
  }
}
