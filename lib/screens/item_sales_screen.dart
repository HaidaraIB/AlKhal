import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:alkhal/widgets/item_sale_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemSalesScreen extends StatefulWidget {
  final Item item;
  final double purchases;
  final double sellings;

  const ItemSalesScreen({
    super.key,
    required this.item,
    required this.purchases,
    required this.sellings,
  });

  @override
  State<ItemSalesScreen> createState() => _ItemSalesScreenState();
}

class _ItemSalesScreenState extends State<ItemSalesScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TransactionItemCubit>(context)
        .loadItems(itemId: widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سجل مبيع/شراء ${widget.item.name.trim()}'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: BlocBuilder<TransactionItemCubit, TransactionItemState>(
        bloc: BlocProvider.of<TransactionItemCubit>(context),
        builder: (context, state) {
          if (state is LoadingTransactionItems) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            );
          } else if (state is LoadingTransactionItemsFailed) {
            return buildErrorWidget(state.err);
          } else if (state is TransactionItemList &&
              state.transactionItems.isNotEmpty) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildNumberWidget(
                      'الشراء',
                      widget.purchases,
                    ),
                    buildNumberWidget(
                      'المبيع',
                      widget.sellings,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.transactionItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ItemSaleCard(
                        item: widget.item,
                        transactionItem:
                            state.transactionItems[index] as TransactionItem,
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text(
                'ليس لديك عناصر بعد!',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 20),
              ),
            );
          }
        },
      ),
    );
  }
}
