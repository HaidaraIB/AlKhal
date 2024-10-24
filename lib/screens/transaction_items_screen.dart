import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/widgets/transaction_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionItems extends StatefulWidget {
  const TransactionItems({
    super.key,
    required this.transactionId,
    required this.isSale,
  });
  final int transactionId;
  final int isSale;

  @override
  State<TransactionItems> createState() => _ItemsState();
}

class _ItemsState extends State<TransactionItems> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TransactionItemCubit>(context)
        .loadItems(widget.transactionId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionItemCubit, TransactionItemState>(
      builder: (context, state) {
        if (state is LoadingTransactionItems) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state is LoadingTransactionItemsFailed) {
          return const Center(
            child: Text(
              "Something went wrong!",
              style: TextStyle(fontSize: 20),
            ),
          );
        } else if (state.transactionItems.isNotEmpty) {
          return ListView.builder(
            itemCount: state.transactionItems.length,
            itemBuilder: (BuildContext context, int index) {
              return TransactionItemCard(
                transactionItem:
                    state.transactionItems[index] as TransactionItem,
                isSale: widget.isSale,
              );
            },
          );
        } else {
          return const Center(
            child: Text(
              '!ليس لديك عناصر بعد',
              style: TextStyle(fontSize: 20),
            ),
          );
        }
      },
    );
  }
}
