import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/item_history.dart';
import 'package:alkhal/models/pending_operation.dart';
import 'package:alkhal/models/spending.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/models/transaction_item.dart';

abstract class Model {
  int? id;
  Model({this.id});
  Map<String, dynamic> toMap();
  factory Model.fromMap(Map<String, dynamic> map, String type) {
    if (type == "Item") {
      return Item.fromMap(map);
    } else if (type == "ItemHistory") {
      return ItemHistory.fromMap(map);
    } else if (type == "Transaction") {
      return Transaction.fromMap(map);
    } else if (type == "TransactionItem") {
      return TransactionItem.fromMap(map);
    } else if (type == "Category") {
      return Category.fromMap(map);
    } else if (type == "Spending") {
      return Spending.fromMap(map);
    } else if (type == "PendingOperation") {
      return PendingOperation.fromMap(map);
    } else {
      throw Exception('Unknown model type');
    }
  }
}
