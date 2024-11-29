import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/spending.dart';
import 'package:alkhal/widgets/spending_card.dart';
import 'package:flutter/material.dart';

class Spendings extends StatefulWidget {
  final List<Model?> spendings;
  final ScrollController? spendingsScrollController;
  const Spendings({
    super.key,
    required this.spendings,
    this.spendingsScrollController,
  });

  @override
  State<Spendings> createState() => _SpendingsState();
}

class _SpendingsState extends State<Spendings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.spendingsScrollController,
      itemCount: widget.spendings.length,
      itemBuilder: (newContext, index) {
        return SpendingCard(
          spending: widget.spendings[index] as Spending,
        );
      },
    );
  }
}
