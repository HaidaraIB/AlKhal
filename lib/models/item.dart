import 'package:alkhal/models/model.dart';
import 'package:alkhal/services/database_helper.dart';
import 'measurement_unit.dart';

class Item extends Model {
  static const String tableName = "item";

  final int categoryId;
  final String name;
  final MeasurementUnit unit;
  double quantity;
  final double purchasePrice;
  final double sellingPrice;

  Item({
    super.id,
    required this.categoryId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.purchasePrice,
    required this.sellingPrice,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'unit': unit.toString().split(".").last,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      unit: MeasurementUnit.fromString(map['unit']),
      quantity: map['quantity'],
      purchasePrice: map['purchase_price'],
      sellingPrice: map['selling_price'],
    );
  }
  // Read by ID
  static Future<Item?> getByName(String? name) async {
    final db = await DatabaseHelper.db;
    final List<Map<String, Object?>>? maps = await db?.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps!.isNotEmpty) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  static Future<Item> getItem(int itemId) async {
    Item item =
        await DatabaseHelper.getById(Item.tableName, "Item", itemId) as Item;
    return item;
  }
}
