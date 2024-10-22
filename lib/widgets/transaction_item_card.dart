import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter/material.dart';

class TransactionItemCard extends StatelessWidget {
  final TransactionItem transactionItem;

  const TransactionItemCard({super.key, required this.transactionItem});
  @override
  Widget build(BuildContext context) {
    Item item =
        DatabaseHelper.getById(Item.tableName, "Item", transactionItem.itemId)
            as Item;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Quantity: ${transactionItem.quantity} ${item.unit}',
            ),
          ],
        ),
      ),
    );
  }
}
