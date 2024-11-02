import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/services/database_helper.dart';

class TransactionItem extends Model {
  static const String tableName = "transaction_item";
  int? transactionId;
  final int itemId;
  final double quantity;
  TransactionItem({
    super.id,
    required this.itemId,
    this.transactionId,
    required this.quantity,
  });
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'item_id': itemId,
      'quantity': quantity,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      transactionId: map['transaction_id'],
      itemId: map['item_id'],
      quantity: map['quantity'],
    );
  }

  static Future computeTransactionCash(
    Transaction transaction,
  ) async {
    List<Model> transactionItems = await DatabaseHelper.getAll(
      tableName,
      "TransactionItem",
      "transaction_id = ?",
      [transaction.id],
    );
    double totalPrice = 0;
    double totalProfit = 0;
    for (Model transactionItem in transactionItems) {
      Model? item = await DatabaseHelper.getById(
        Item.tableName,
        "Item",
        (transactionItem as TransactionItem).itemId,
      );
      bool isKg = (item as Item).unit == MeasurementUnit.kg;
      double sellingPrice = 0;
      double purchasePrice = 0;
      if (isKg) {
        sellingPrice = item.sellingPrice * transactionItem.quantity / 1000;
        purchasePrice = item.purchasePrice * transactionItem.quantity / 1000;
      } else {
        sellingPrice = item.sellingPrice * transactionItem.quantity;
        purchasePrice = item.purchasePrice * transactionItem.quantity;
      }
      if (transaction.isSale == 1) {
        totalProfit += sellingPrice - purchasePrice;
      }
      totalPrice += transaction.isSale == 1 ? sellingPrice : purchasePrice;
    }
    transaction.totalPrice = totalPrice;
    transaction.totalProfit = totalProfit;
    await DatabaseHelper.update(Transaction.tableName, transaction);
  }
}
