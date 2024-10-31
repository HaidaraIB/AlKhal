import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';

class TransactionItemCard extends StatefulWidget {
  final TransactionItem transactionItem;
  final bool isSale;

  const TransactionItemCard({
    super.key,
    required this.transactionItem,
    required this.isSale,
  });

  @override
  State<TransactionItemCard> createState() => _TransactionItemCardState();
}

class _TransactionItemCardState extends State<TransactionItemCard> {
  late Future<Item> _getItem;
  @override
  void initState() {
    super.initState();
    _getItem = Item.getItem((widget.transactionItem.itemId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getItem,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TransactoinItemCardWidget(
            quantity: (snapshot.data!.unit.name == "kg" && !widget.isSale)
                ? formatDouble(widget.transactionItem.quantity / 1000)
                : formatDouble(widget.transactionItem.quantity),
            itemName: snapshot.data!.name,
            unit: (snapshot.data!.unit.name == 'kg')
                ? (widget.isSale ? "غرام" : "كيلو غرام")
                : "قطعة",
            price: (snapshot.data!.unit.name == "kg")
                ? formatDouble(
                    widget.transactionItem.quantity /
                        1000 *
                        (widget.isSale
                            ? snapshot.data!.sellingPrice
                            : snapshot.data!.purchasePrice),
                  )
                : formatDouble(
                    widget.transactionItem.quantity *
                        (widget.isSale
                            ? snapshot.data!.sellingPrice
                            : snapshot.data!.purchasePrice),
                  ),
            profit: widget.isSale
                ? (snapshot.data!.unit.name == "kg")
                    ? formatDouble(widget.transactionItem.quantity /
                            1000 *
                            snapshot.data!.sellingPrice -
                        widget.transactionItem.quantity /
                            1000 *
                            snapshot.data!.purchasePrice)
                    : formatDouble(widget.transactionItem.quantity *
                            snapshot.data!.sellingPrice -
                        widget.transactionItem.quantity *
                            snapshot.data!.purchasePrice)
                : null,
          );
        } else {
          return TransactoinItemCardWidget(
            quantity: widget.transactionItem.quantity.toString(),
            itemName: '-',
            unit: '-',
            price: '0',
            profit: widget.isSale ? '0' : null,
          );
        }
      },
    );
  }
}

class TransactoinItemCardWidget extends StatelessWidget {
  const TransactoinItemCardWidget({
    super.key,
    required this.quantity,
    required this.itemName,
    required this.unit,
    required this.price,
    required this.profit,
  });

  final String quantity;
  final String itemName;
  final String unit;
  final String price;
  final String? profit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Column(
              children: [
                Text(
                  'الكمية: $quantity $unit',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  'السعر: $price ل.س',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                profit != null
                    ? Text(
                        'الربح: $profit ل.س',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            Text(
              itemName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}