import 'package:alkhal/models/model.dart';

class TransactionItem extends Model {
  static const String tableName = "transaction_item";
  final int transactionId;
  final int itemId;
  final double quantity;
  TransactionItem({
    super.id,
    required this.itemId,
    required this.transactionId,
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
}
