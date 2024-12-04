import 'dart:io';
import 'dart:typed_data';
import 'package:alkhal/models/model.dart';
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

  static Future _initDatabase() async {
    String dbName = "${(await User.userInfo())['username']}.db";
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, dbName);
    // await deleteDatabase(path);
    // await clearSharedPref();
    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 6,
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
    }
  }

  static _onCreate(Database db, int version) async {
    await db.execute("""
        CREATE TABLE category (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        );
      """);
    await db.execute("""
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
      """);
    await db.execute("""
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
      """);
    await db.execute("""
        CREATE TABLE 'transaction' (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transaction_date TIMESTAMP,
          discount REAL,
          remainder REAL,
          total_price REAL,
          total_profit REAL,
          is_sale INTEGER
        );
      """);
    await db.execute("""
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
      """);
    await db.execute("""
        CREATE TABLE spending (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL,
          notes TEXT,
          spending_date TIMESTAMP
        );
      """);
    await db.execute("""
      CREATE TRIGGER delete_transaction_after_items_deleted
      AFTER DELETE ON transaction_item
      BEGIN
        DELETE FROM 'transaction'
        WHERE id NOT IN (SELECT DISTINCT transaction_id FROM transaction_item);
      END;
    """);
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

  static Future<bool> remoteBackupDatabase() async {
    String dbName = "${(await User.userInfo())['username']}.db";
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, dbName);
    final dbFile = File(dbPath);
    if (!(await dbFile.exists())) {
      return false;
    }
    final newDbHash = await calculateFileHash(dbFile);
    final prefs = await SharedPreferences.getInstance();
    final lastDbHash = prefs.getString(dbHashKey) ?? '';
    if (newDbHash != lastDbHash) {
      var r = await ApiCalls.remoteBackupDatabase(dbFile);
      await prefs.setString(dbHashKey, newDbHash);
      return r.statusCode == 201;
    } else {
      return false;
    }
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
  static Future<Model?> getById(String tableName, String model, int id) async {
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
  static Future<int?> delete(String tableName, int id) async {
    final db = await DatabaseHelper.db;
    return await db?.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<Map<String, dynamic>> computeCash(
      DateTime startDate, DateTime endDate) async {
    final db = await DatabaseHelper.db;
    final List<Map<String, dynamic>>? cashResult = await db?.rawQuery(
      '''
      SELECT 
        SUM(total_price) as cash,
        SUM(total_profit) as profit,
        SUM(remainder) as remainders,
        SUM(discount) as discounts
      FROM 
        'transaction'
      WHERE is_sale = 1 AND date(transaction_date) BETWEEN '${dateToISO(startDate)}' AND '${dateToISO(endDate)}';
      ''',
    );
    final List<Map<String, dynamic>>? billsResult = await db?.rawQuery(
      '''
      SELECT 
        SUM(total_price) as bills 
      FROM 
        'transaction'
      WHERE is_sale = 0 AND date(transaction_date) BETWEEN '${dateToISO(startDate)}' AND '${dateToISO(endDate)}';
      ''',
    );

    final List<Map<String, dynamic>>? spendingsResult = await db?.rawQuery(
      '''
      SELECT 
        SUM(amount) as spendings 
      FROM 
        spending
      WHERE date(spending_date) BETWEEN '${dateToISO(startDate)}' AND '${dateToISO(endDate)}';
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
