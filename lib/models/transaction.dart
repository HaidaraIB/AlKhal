import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/services/database_helper.dart';

class Transaction extends Model {
  static const String tableName = 'transaction';

  final double discount;
  final double reminder;
  double totalPrice;
  double totalProfit;
  final String transactionDate;
  final int isSale;
  final String notes;

  Transaction({
    super.id,
    required this.discount,
    required this.reminder,
    required this.transactionDate,
    required this.isSale,
    required this.totalPrice,
    required this.totalProfit,
    required this.notes,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'discount': discount,
      'reminder': reminder,
      'transaction_date': transactionDate,
      'is_sale': isSale,
      'total_price': totalPrice,
      'total_profit': totalProfit,
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      discount: map['discount'],
      reminder: map['reminder'],
      transactionDate: map['transaction_date'],
      isSale: map['is_sale'],
      totalPrice: map['total_price'],
      totalProfit: map['total_profit'] ?? 0,
      notes: map['notes'],
    );
  }

  static Future<void> addTransaction(
    Transaction transaction,
    List<TransactionItem> transactionItems,
    List<Item> itemsToUpdate,
  ) async {
    final db = await DatabaseHelper.db;
    await db!.transaction((txn) async {
      int? transactionId =
          await txn.insert(Transaction.tableName, transaction.toMap());
      for (int i = 0; i < transactionItems.length; i++) {
        transactionItems[i].transactionId = transactionId;
        await txn.insert(
            TransactionItem.tableName, transactionItems[i].toMap());
        if (transaction.isSale == 1) {
          itemsToUpdate[i].quantity -= transactionItems[i].quantity;
        } else {
          itemsToUpdate[i].quantity += transactionItems[i].quantity;
        }

        await txn.update(
          Item.tableName,
          itemsToUpdate[i].toMap(),
          where: "id = ?",
          whereArgs: [itemsToUpdate[i].id],
        );
      }
    });
  }
}
