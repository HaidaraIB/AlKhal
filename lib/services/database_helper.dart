import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/pending_operation.dart';
import 'package:alkhal/models/spending_status.dart';
import 'package:alkhal/models/user.dart';
import 'package:alkhal/services/api_calls.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const externalDbPath = "/storage/emulated/0/AlKhal/database";
  static const String dbHashKey = 'db_hash_key';
  static Database? _db;

  static Future<Database?> get db async {
    if (_db == null) {
      _db = await _initDatabase();
      return _db;
    } else {
      return _db;
    }
  }

  static Future<Database?> _initDatabase() async {
    String dbName = "${(await User.userInfo())['username']}.db";
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, dbName);
    // await deleteDatabase(path);
    // await clearSharedPref();
    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 8,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
    return mydb;
  }

  static _onOpen(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON;");
  }

  static _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 4) {
      await db.execute("ALTER TABLE 'transaction' ADD notes TEXT DEFAULT '';");
      await db.execute("ALTER TABLE transaction_item ADD purchase_price REAL;");
      await db.execute("ALTER TABLE transaction_item ADD selling_price REAL;");
      await db.execute(
        """
        UPDATE transaction_item
        SET purchase_price = (
          SELECT purchase_price
          FROM item
          WHERE item.id = transaction_item.item_id
        ),
        selling_price = (
          SELECT selling_price
          FROM item
          WHERE item.id = transaction_item.item_id
        );
      """,
      );
    } else if (newVersion == 5) {
      await db.execute(
        "ALTER TABLE 'transaction' RENAME COLUMN reminder TO remainder;",
      );
    } else if (newVersion == 6) {
      await db.execute("""
        CREATE TABLE spending (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL,
          notes TEXT,
          spending_date TIMESTAMP
        );
      """);
    } else if (newVersion == 7) {
      await db
          .execute("ALTER TABLE spending ADD status TEXT DEFAULT 'active';");
    } else if (newVersion == 8) {
      await db.execute("""
        CREATE TABLE pending_operations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          operation TEXT, -- 'insert', 'update', 'delete'
          table_name TEXT, -- The table being modified (e.g., 'category', 'item', etc.)
          record_id INTEGER, -- The ID of the record being modified
          data TEXT, -- JSON representation of the data
          timestamp INTEGER, -- Timestamp of the operation
          uuid TEXT DEFAULT '${await getOrCreateUUID()}' -- Unique id to distinguish users
        );
      """);
      await _createTriggersForCategoryTable(db);
      await _createTriggersForItemTable(db);
      await _createTriggersForItemHistoryTable(db);
      await _createTriggersForTransactionTable(db);
      await _createTriggerForTransactionItemTable(db);
      await _createTriggersForSpendingTable(db);
    }
  }

  static _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createTriggersForCategoryTable(db);
    await _createTriggersForItemTable(db);
    await _createTriggersForItemHistoryTable(db);
    await _createTriggersForTransactionTable(db);
    await _createTriggerForTransactionItemTable(db);
    await _createTriggersForSpendingTable(db);
  }

  static Future<void> _createTables(Database db) async {
    final tables = [
      """
    CREATE TABLE category (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    );
    """,
      """
    CREATE TABLE item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER,
      name TEXT,
      quantity REAL,
      unit TEXT,
      purchase_price REAL,
      selling_price REAL,
      FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE CASCADE
    );
    """,
      """
    CREATE TABLE item_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_id INTEGER,
      old_name TEXT,
      new_name TEXT,
      old_category_id INTEGER,
      new_category_id INTEGER,
      old_selling_price REAL,
      new_selling_price REAL,
      old_purchase_price REAL,
      new_purchase_price REAL,
      update_date TIMESTAMP,
      FOREIGN KEY (item_id) REFERENCES item (id) ON DELETE CASCADE
    );
    """,
      """
    CREATE TABLE 'transaction' (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_date TIMESTAMP,
      discount REAL,
      remainder REAL,
      total_price REAL,
      total_profit REAL,
      is_sale INTEGER,
      notes TEXT
    );
    """,
      """
    CREATE TABLE transaction_item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_id INTEGER,
      item_id INTEGER,
      quantity REAL,
      purchase_price REAL,
      selling_price REAL,
      FOREIGN KEY (item_id) REFERENCES item (id) ON DELETE CASCADE,
      FOREIGN KEY (transaction_id) REFERENCES 'transaction' (id) ON DELETE CASCADE
    );
    """,
      """
    CREATE TABLE spending (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL,
      notes TEXT,
      spending_date TIMESTAMP,
      status TEXT DEFAULT 'active'
    );
    """,
      """
    CREATE TABLE pending_operations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      operation TEXT, -- 'insert', 'update', 'delete'
      table_name TEXT, -- The table being modified (e.g., 'category', 'item', etc.)
      record_id INTEGER, -- The ID of the record being modified
      data TEXT, -- JSON representation of the data
      timestamp INTEGER, -- Timestamp of the operation
      uuid TEXT DEFAULT '${await getOrCreateUUID()}' -- Unique id to distinguish users
    );
    """,
      // Trigger to delete transactions with no items
      """
    CREATE TRIGGER delete_transaction_after_items_deleted
    AFTER DELETE ON transaction_item
    BEGIN
      DELETE FROM 'transaction'
      WHERE id NOT IN (SELECT DISTINCT transaction_id FROM transaction_item);
    END;
    """,
    ];

    for (final table in tables) {
      await db.execute(table);
    }
  }

  static Future<void> _createTriggersForCategoryTable(Database db) async {
    final triggers = [
      // Trigger for INSERT
      """
    CREATE TRIGGER log_insert_category
    AFTER INSERT ON category
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('insert', 'category', NEW.id, '{"id": ' || NEW.id || ', "name": "' || NEW.name || '"}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for UPDATE
      """
    CREATE TRIGGER log_update_category
    AFTER UPDATE ON category
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('update', 'category', NEW.id, '{"id": ' || NEW.id || ', "name": "' || NEW.name || '"}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for DELETE
      """
    CREATE TRIGGER log_delete_category
    AFTER DELETE ON category
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('delete', 'category', OLD.id, '{"id": ' || OLD.id || ', "name": "' || OLD.name || '"}', strftime('%s', 'now'));
    END;
    """,
    ];
    for (final trigger in triggers) {
      await db.execute(trigger);
    }
  }

  static Future<void> _createTriggersForItemTable(Database db) async {
    final triggers = [
      // Trigger for INSERT
      """
    CREATE TRIGGER log_insert_item
    AFTER INSERT ON item
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('insert', 'item', NEW.id, '{"id": ' || NEW.id || ', "category_id": ' || NEW.category_id || ', "name": "' || NEW.name || '", "quantity": ' || NEW.quantity || ', "unit": "' || NEW.unit || '", "purchase_price": ' || NEW.purchase_price || ', "selling_price": ' || NEW.selling_price || '}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for UPDATE
      """
    CREATE TRIGGER log_update_item
    AFTER UPDATE ON item
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('update', 'item', NEW.id, '{"id": ' || NEW.id || ', "category_id": ' || NEW.category_id || ', "name": "' || NEW.name || '", "quantity": ' || NEW.quantity || ', "unit": "' || NEW.unit || '", "purchase_price": ' || NEW.purchase_price || ', "selling_price": ' || NEW.selling_price || '}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for DELETE
      """
    CREATE TRIGGER log_delete_item
    AFTER DELETE ON item
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('delete', 'item', OLD.id, '{"id": ' || OLD.id || ', "category_id": ' || OLD.category_id || ', "name": "' || OLD.name || '", "quantity": ' || OLD.quantity || ', "unit": "' || OLD.unit || '", "purchase_price": ' || OLD.purchase_price || ', "selling_price": ' || OLD.selling_price || '}', strftime('%s', 'now'));
    END;
    """,
    ];
    for (final trigger in triggers) {
      await db.execute(trigger);
    }
  }

  static Future<void> _createTriggersForItemHistoryTable(Database db) async {
    final triggers = [
      // Trigger for INSERT
      """
    CREATE TRIGGER log_insert_item_history
    AFTER INSERT ON item_history
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('insert', 'item_history', NEW.id, '{"id": ' || NEW.id || ', "item_id": ' || NEW.item_id || ', "old_name": "' || NEW.old_name || '", "new_name": "' || NEW.new_name || '", "old_category_id": ' || NEW.old_category_id || ', "new_category_id": ' || NEW.new_category_id || ', "old_selling_price": ' || NEW.old_selling_price || ', "new_selling_price": ' || NEW.new_selling_price || ', "old_purchase_price": ' || NEW.old_purchase_price || ', "new_purchase_price": ' || NEW.new_purchase_price || ', "update_date": "' || NEW.update_date || '"}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for UPDATE
      """
    CREATE TRIGGER log_update_item_history
    AFTER UPDATE ON item_history
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('update', 'item_history', NEW.id, '{"id": ' || NEW.id || ', "item_id": ' || NEW.item_id || ', "old_name": "' || NEW.old_name || '", "new_name": "' || NEW.new_name || '", "old_category_id": ' || NEW.old_category_id || ', "new_category_id": ' || NEW.new_category_id || ', "old_selling_price": ' || NEW.old_selling_price || ', "new_selling_price": ' || NEW.new_selling_price || ', "old_purchase_price": ' || NEW.old_purchase_price || ', "new_purchase_price": ' || NEW.new_purchase_price || ', "update_date": "' || NEW.update_date || '"}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for DELETE
      """
    CREATE TRIGGER log_delete_item_history
    AFTER DELETE ON item_history
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('delete', 'item_history', OLD.id, '{"id": ' || OLD.id || ', "item_id": ' || OLD.item_id || ', "old_name": "' || OLD.old_name || '", "new_name": "' || OLD.new_name || '", "old_category_id": ' || OLD.old_category_id || ', "new_category_id": ' || OLD.new_category_id || ', "old_selling_price": ' || OLD.old_selling_price || ', "new_selling_price": ' || OLD.new_selling_price || ', "old_purchase_price": ' || OLD.old_purchase_price || ', "new_purchase_price": ' || OLD.new_purchase_price || ', "update_date": "' || OLD.update_date || '"}', strftime('%s', 'now'));
    END;
    """,
    ];
    for (final trigger in triggers) {
      await db.execute(trigger);
    }
  }

  static Future<void> _createTriggersForTransactionTable(Database db) async {
    final triggers = [
      // Trigger for INSERT
      """
    CREATE TRIGGER log_insert_transaction
    AFTER INSERT ON 'transaction'
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('insert', 'transaction', NEW.id, '{"id": ' || NEW.id || ', "transaction_date": "' || NEW.transaction_date || '", "discount": ' || NEW.discount || ', "remainder": ' || NEW.remainder || ', "total_price": ' || NEW.total_price || ', "total_profit": ' || NEW.total_profit || ', "is_sale": ' || NEW.is_sale || ', "notes": "' || NEW.notes || '"}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for UPDATE
      """
    CREATE TRIGGER log_update_transaction
    AFTER UPDATE ON 'transaction'
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('update', 'transaction', NEW.id, '{"id": ' || NEW.id || ', "transaction_date": "' || NEW.transaction_date || '", "discount": ' || NEW.discount || ', "remainder": ' || NEW.remainder || ', "total_price": ' || NEW.total_price || ', "total_profit": ' || NEW.total_profit || ', "is_sale": ' || NEW.is_sale || ', "notes": "' || NEW.notes || '"}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for DELETE
      """
    CREATE TRIGGER log_delete_transaction
    AFTER DELETE ON 'transaction'
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('delete', 'transaction', OLD.id, '{"id": ' || OLD.id || ', "transaction_date": "' || OLD.transaction_date || '", "discount": ' || OLD.discount || ', "remainder": ' || OLD.remainder || ', "total_price": ' || OLD.total_price || ', "total_profit": ' || OLD.total_profit || ', "is_sale": ' || OLD.is_sale || ', "notes": "' || OLD.notes || '"}', strftime('%s', 'now'));
    END;
    """,
    ];
    for (final trigger in triggers) {
      await db.execute(trigger);
    }
  }

  static Future<void> _createTriggerForTransactionItemTable(Database db) async {
    final triggers = [
      // Trigger for INSERT
      """
    CREATE TRIGGER log_insert_transaction_item
    AFTER INSERT ON transaction_item
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('insert', 'transaction_item', NEW.id, '{"id": ' || NEW.id || ', "transaction_id": ' || NEW.transaction_id || ', "item_id": ' || NEW.item_id || ', "quantity": ' || NEW.quantity || ', "purchase_price": ' || NEW.purchase_price || ', "selling_price": ' || NEW.selling_price || '}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for UPDATE
      """
    CREATE TRIGGER log_update_transaction_item
    AFTER UPDATE ON transaction_item
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('update', 'transaction_item', NEW.id, '{"id": ' || NEW.id || ', "transaction_id": ' || NEW.transaction_id || ', "item_id": ' || NEW.item_id || ', "quantity": ' || NEW.quantity || ', "purchase_price": ' || NEW.purchase_price || ', "selling_price": ' || NEW.selling_price || '}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for DELETE
      """
    CREATE TRIGGER log_delete_transaction_item
    AFTER DELETE ON transaction_item
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('delete', 'transaction_item', OLD.id, '{"id": ' || OLD.id || ', "transaction_id": ' || OLD.transaction_id || ', "item_id": ' || OLD.item_id || ', "quantity": ' || OLD.quantity || ', "purchase_price": ' || OLD.purchase_price || ', "selling_price": ' || OLD.selling_price || '}', strftime('%s', 'now'));
    END;
    """,
    ];
    for (final trigger in triggers) {
      await db.execute(trigger);
    }
  }

  static Future<void> _createTriggersForSpendingTable(Database db) async {
    final triggers = [
      // Trigger for INSERT
      """
    CREATE TRIGGER log_insert_spending
    AFTER INSERT ON spending
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('insert', 'spending', NEW.id, '{"id": ' || NEW.id || ', "amount": ' || NEW.amount || ', "notes": "' || NEW.notes || '", "spending_date": "' || NEW.spending_date || '", "status": "' || NEW.status || '"}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for UPDATE
      """
    CREATE TRIGGER log_update_spending
    AFTER UPDATE ON spending
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('update', 'spending', NEW.id, '{"id": ' || NEW.id || ', "amount": ' || NEW.amount || ', "notes": "' || NEW.notes || '", "spending_date": "' || NEW.spending_date || '", "status": "' || NEW.status || '"}', strftime('%s', 'now'));
    END;
    """,
      // Trigger for DELETE
      """
    CREATE TRIGGER log_delete_spending
    AFTER DELETE ON spending
    BEGIN
      INSERT INTO pending_operations (operation, table_name, record_id, data, timestamp)
      VALUES ('delete', 'spending', OLD.id, '{"id": ' || OLD.id || ', "amount": ' || OLD.amount || ', "notes": "' || OLD.notes || '", "spending_date": "' || OLD.spending_date || '", "status": "' || OLD.status || '"}', strftime('%s', 'now'));
    END;
    """,
    ];
    for (final trigger in triggers) {
      await db.execute(trigger);
    }
  }

  static Future<int> syncPendingOperations() async {
    final db = await DatabaseHelper.db;
    var r = await ApiCalls.getRemoteDb((await User.userInfo())['username']);
    if (![200, 503].contains(r.statusCode)) {
      int res = await remoteBackupDatabase();
      await db!.delete('pending_operations');
      return res;
    } else if (r.statusCode == 503) {
      return 503;
    }

    final pendingOperations = await getAll(
      PendingOperation.tableName,
      "PendingOperation",
      orderBy: "timestamp ASC",
    );
    if (pendingOperations.isEmpty) {
      return -200;
    }
    r = await ApiCalls.syncPendingOperations(
      (await User.userInfo())['username'],
      pendingOperations.map((p) => p.toMap()).toList(),
    );

    if (r.statusCode == 200) {
      await db!.delete('pending_operations');
      return 200;
    } else {
      throw Exception('Failed to sync pending operations');
    }
  }

  static Future<int> getPendingOperations(
    String username,
    int lastPendingOperationId,
  ) async {
    // get the pending operations
    var r = await ApiCalls.getPendingOperations(
      username,
      lastPendingOperationId,
    );

    if (r.statusCode != 200) {
      return r.statusCode;
    }
    List rawPendingOperations = jsonDecode(r.body)['operations'];
    if (rawPendingOperations.isEmpty) {
      return -200;
    }
    // convert to PendingOperation model
    List<PendingOperation> pendingOperations = rawPendingOperations
        .map(
          (e) => PendingOperation.fromMap(e),
        )
        .toList();

    final db = await DatabaseHelper.db;
    for (PendingOperation o in pendingOperations) {
      switch (o.operation) {
        case "insert":
          String columns = o.data.keys.join(", ");
          String values = o.data.values
              .map(
                (e) => "'$e'",
              )
              .toList()
              .join(", ");
          db!.rawInsert(
              "INSERT INTO '${o.tName}' ($columns) VALUES ($values);");
          break;

        case "update":
          String updates = o.data.keys
              .map(
                (k) => "$k = '${o.data[k]}'",
              )
              .toList()
              .join(", ");

          db!.rawUpdate(
              "UPDATE '${o.tName}' SET $updates WHERE id = ${o.recordId};");
          break;

        case "delete":
          db!.rawDelete("DELETE FROM '${o.tName}' WHERE id = ${o.recordId};");
          break;

        default:
          continue;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      "last_pending_operation_id",
      pendingOperations.last.id!,
    );
    return r.statusCode;
  }

  static Future<int> remoteBackupDatabase() async {
    String dbName = "${(await User.userInfo())['username']}.db";
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, dbName);
    final dbFile = File(dbPath);
    if (!(await dbFile.exists())) {
      return -200; // means local success, no need to change anything
    }
    final newDbHash = await calculateFileHash(dbFile);
    final prefs = await SharedPreferences.getInstance();
    final lastDbHash = prefs.getString(dbHashKey) ?? '';
    if (newDbHash != lastDbHash) {
      var r = await ApiCalls.remoteBackupDatabase(dbFile);
      await prefs.setString(dbHashKey, newDbHash);
      return r.statusCode;
    } else {
      return -200;
    }
  }

  static Future<bool> localBackupDatabase() async {
    await createDirectory();
    String dbName = "${(await User.userInfo())['username']}.db";
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, dbName);
    final backupPath = join(externalDbPath, dbName);

    final dbFile = File(dbPath);
    final backupFile = File(backupPath);

    if (await backupFile.exists()) {
      await backupFile.delete();
    }
    await dbFile.copy(backupFile.path);
    return true;
  }

  static Future<bool> restoreLocalDatabase() async {
    await createDirectory();
    String dbName = "${(await User.userInfo())['username']}.db";
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, dbName);
    final backupPath = join(externalDbPath, dbName);

    final backupFile = File(backupPath);
    final dbFile = File(dbPath);

    if (await backupFile.exists()) {
      if (await dbFile.exists()) {
        await deleteDatabase(dbPath);
      }
      await backupFile.copy(dbFile.path);
      _db = null;
      await _initDatabase();
      return true;
    } else {
      return false;
    }
  }

  static Future restoreRemoteDatabase(Uint8List bytes) async {
    await createDirectory();
    String dbName = "${(await User.userInfo())['username']}.db";
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, dbName);

    final dbFile = File(dbPath);

    if (await dbFile.exists()) {
      await deleteDatabase(dbPath);
    }
    await dbFile.writeAsBytes(bytes);
    _db = null;
    await _initDatabase();

    // getting the last pending operation to store its timestamp.
    final db = await DatabaseHelper.db;
    var lastPendingOperationId = await db!.rawQuery(
        "SELECT MAX(id) as last_pending_operation_id FROM ${PendingOperation.tableName}");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      "last_pending_operation_id",
      lastPendingOperationId.isNotEmpty
          ? int.parse(lastPendingOperationId.first['last_pending_operation_id']
              .toString())
          : 0,
    );
    await deleteAll(PendingOperation.tableName);
    return true;
  }

  static Future shareDatabase() async {
    String dbName = "${(await User.userInfo())['username']}.db";
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, dbName);
    Share.shareXFiles([XFile(dbPath)], text: 'AlKhal');
  }

  static Future<void> createDirectory() async {
    final Directory storageDir = Directory(externalDbPath);

    if (!await storageDir.exists()) {
      try {
        await storageDir.create(recursive: true);
      } catch (e) {
        debugPrint("Error creating directory: $e");
      }
    }
  }
  // CRUD operations

  // Create
  static Future<int?> insert(String tableName, Model model) async {
    final db = await DatabaseHelper.db;
    try {
      return await db?.insert(tableName, model.toMap());
    } catch (e) {
      return -1;
    }
  }

  // Read all
  static Future<List<Model>> getAll(
    String tableName,
    String model, {
    String? where,
    List? whereArgs,
    String? orderBy,
  }) async {
    final db = await DatabaseHelper.db;
    final List<Map<String, Object?>>? maps = await db?.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return List.generate(maps!.length, (i) => Model.fromMap(maps[i], model));
  }

  // Read by ID
  static Future<Model?> getById(String tableName, String model, id) async {
    final db = await DatabaseHelper.db;
    final List<Map<String, Object?>>? maps = await db?.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps!.isNotEmpty) {
      return Model.fromMap(maps.first, model);
    }
    return null;
  }

  // Update
  static Future<int?> update(String tableName, Model model) async {
    final db = await DatabaseHelper.db;
    return await db?.update(
      tableName,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  // Delete
  static Future<int?> deleteOne(String tableName, int id) async {
    final db = await DatabaseHelper.db;
    return await db?.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int?> deleteAll(String tableName) async {
    final db = await DatabaseHelper.db;
    return await db?.delete(tableName);
  }

  static Future<Map<String, dynamic>> computeCash(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DatabaseHelper.db;
    String startISODate = dateToISO(startDate);
    String endISODate = dateToISO(endDate);
    final List<Map<String, dynamic>>? cashResult = await db?.rawQuery(
      '''
      SELECT 
        SUM(total_price) as cash,
        SUM(total_profit) as profit,
        SUM(remainder) as remainders,
        SUM(discount) as discounts
      FROM 
        'transaction'
      WHERE is_sale = 1 AND date(transaction_date) BETWEEN '$startISODate' AND '$endISODate';
      ''',
    );
    final List<Map<String, dynamic>>? billsResult = await db?.rawQuery(
      '''
      SELECT 
        SUM(total_price) as bills 
      FROM 
        'transaction'
      WHERE is_sale = 0 AND date(transaction_date) BETWEEN '$startISODate' AND '$endISODate';
      ''',
    );

    final List<Map<String, dynamic>>? spendingsResult = await db?.rawQuery(
      '''
      SELECT 
        SUM(amount) as spendings 
      FROM 
        spending
      WHERE status = '${SpendingStatus.active.value}' AND date(spending_date) BETWEEN '$startISODate' AND '$endISODate';
      ''',
    );

    if (cashResult!.isNotEmpty) {
      return {
        'cash': cashResult.first['cash'] ?? 0.0,
        'profit': cashResult.first['profit'] ?? 0.0,
        'bills': billsResult!.first['bills'] ?? 0.0,
        'remainders': cashResult.first['remainders'] ?? 0.0,
        'discounts': cashResult.first['discounts'] ?? 0.0,
        'spendings': spendingsResult!.first['spendings'] ?? 0.0,
      };
    } else {
      return {
        'cash': 0.0,
        'profit': 0.0,
        'bills': 0.0,
        'remainders': 0.0,
        'spendings': 0.0,
        'discounts': 0.0,
      };
    }
  }
}
