import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/widgets/transaction_card.dart';
import 'package:flutter/material.dart';

class Transactions extends StatefulWidget {
  final List<Model> transactions;
  final ScrollController? transactionsScrollController;
  const Transactions({
    super.key,
    required this.transactions,
    this.transactionsScrollController,
  });

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.transactionsScrollController,
      itemCount: widget.transactions.length,
      itemBuilder: (newContext, index) {
        return TransactionCard(
          transaction: widget.transactions[index] as Transaction,
        );
      },
    );
  }
}
