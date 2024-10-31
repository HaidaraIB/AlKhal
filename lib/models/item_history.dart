import 'package:alkhal/models/model.dart';

class ItemHistory extends Model {
  static const String tableName = 'item_history';

  final int itemId;
  final String oldName;
  final String newName;
  final int oldCategoryId;
  final int newCategoryId;
  final double oldSellingPrice;
  final double newSellingPrice;
  final double oldPurchasePrice;
  final double newPurchasePrice;
  final String updateDate;

  ItemHistory({
    super.id,
    required this.itemId,
    required this.oldName,
    required this.newName,
    required this.oldCategoryId,
    required this.newCategoryId,
    required this.oldSellingPrice,
    required this.newSellingPrice,
    required this.oldPurchasePrice,
    required this.newPurchasePrice,
    required this.updateDate,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'old_name': oldName,
      'new_name': newName,
      'old_category_id': oldCategoryId,
      'new_category_id': newCategoryId,
      'old_selling_price': oldSellingPrice,
      'new_selling_price': newSellingPrice,
      'old_purchase_price': oldPurchasePrice,
      'new_purchase_price': newPurchasePrice,
      'update_date': updateDate,
    };
  }

  factory ItemHistory.fromMap(Map<String, dynamic> map) {
    return ItemHistory(
      id: map['id'],
      itemId: map['item_id'],
      oldName: map['old_name'],
      newName: map['new_name'],
      oldCategoryId: map['old_category_id'],
      newCategoryId: map['new_category_id'],
      oldSellingPrice: map['old_selling_price'],
      newSellingPrice: map['new_selling_price'],
      oldPurchasePrice: map['old_purchase_price'],
      newPurchasePrice: map['new_purchase_price'],
      updateDate: map['update_date'],
    );
  }
}
