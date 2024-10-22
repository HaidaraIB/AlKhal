import 'package:alkhal/models/model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
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
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'warehouse.db');
    // await deleteDatabase(path);
    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onUpgrade: _onUpgrade,
    );
    return mydb;
  }

  static _onUpgrade(Database db, int oldversion, int newversion) async {}

  static _onCreate(Database db, int version) async {
    await db.execute("PRAGMA foreign_keys = ON;");
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
        CREATE TABLE price_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_id INTEGER,
          date TEXT,
          price REAL,
          FOREIGN KEY (item_id) REFERENCES item (id) ON DELETE CASCADE
        );
      """);
    await db.execute("""
        CREATE TABLE 'transaction' (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          discount REAL,
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
          FOREIGN KEY (item_id) REFERENCES item (id) ON DELETE CASCADE,
          FOREIGN KEY (transaction_id) REFERENCES 'transaction' (id) ON DELETE CASCADE
        );
      """);
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
    String model, [
    String? where,
    List? whereArgs,
  ]) async {
    final db = await DatabaseHelper.db;
    final List<Map<String, Object?>>? maps = await db?.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
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

  static Future<Map<String, dynamic>> computeCash() async {
    final db = await DatabaseHelper.db;
    final List<Map<String, dynamic>>? cashResult = await db?.rawQuery(
      '''
      SELECT 
        SUM(total_price) as cash,
        SUM(total_profit) as profit
      FROM 
        'transaction'
      WHERE is_sale = 1;
        ''',
    );
    final List<Map<String, dynamic>>? billsResult = await db?.rawQuery(
      '''
      SELECT 
        SUM(total_price) as bills
      FROM 
        'transaction'
      WHERE is_sale = 0;
        ''',
    );

    if (cashResult!.isNotEmpty) {
      return {
        'cash': cashResult.first['cash'] ?? 0.0,
        'profit': cashResult.first['profit'] ?? 0.0,
        'bills': billsResult!.first['bills'] ?? 0.0,
      };
    } else {
      return {
        'cash': 0.0,
        'profit': 0.0,
        'bills': 0.0,
      };
    }
  }
}
