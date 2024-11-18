import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/measurement_unit.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:alkhal/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemSaleCard extends StatefulWidget {
  final TransactionItem transactionItem;
  final Item item;

  const ItemSaleCard({
    super.key,
    required this.transactionItem,
    required this.item,
  });

  @override
  State<ItemSaleCard> createState() => _ItemSaleCardState();
}

class _ItemSaleCardState extends State<ItemSaleCard>
    with AutomaticKeepAliveClientMixin {
  Future<Model?> _getTransaction() async {
    return await DatabaseHelper.getById(
      Transaction.tableName,
      "Transaction",
      widget.transactionItem.transactionId!,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Model?>(
      future: _getTransaction(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          );
        }
        if (snapshot.hasData) {
          final Transaction transaction = snapshot.data! as Transaction;
          return Card(
            margin: const EdgeInsets.only(top: 15, right: 15, left: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Banner(
                location: BannerLocation.topStart,
                message: transaction.isSale == 1 ? "مبيع" : "شراء",
                color: transaction.isSale == 1 ? Colors.green : Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          arDateTimeFormat.format(
                              DateTime.parse(transaction.transactionDate)),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.deepPurple,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final transactionItemCubit =
                                BlocProvider.of<TransactionItemCubit>(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (newContext) {
                                  return MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(
                                        value: transactionItemCubit,
                                      ),
                                      BlocProvider(
                                        create: (newContext) =>
                                            TransactionCubit(),
                                      ),
                                    ],
                                    child: PopScope(
                                      canPop: true,
                                      onPopInvokedWithResult:
                                          (didPop, result) async {
                                        await transactionItemCubit.loadItems(
                                          itemId: widget.item.id,
                                        );
                                      },
                                      child: Scaffold(
                                        appBar: AppBar(
                                          title: Text(
                                            "فاتورة ${widget.item.name.trim()}",
                                          ),
                                        ),
                                        body: BlocBuilder<TransactionCubit,
                                            TransactionState>(
                                          builder: (context, state) {
                                            if (state
                                                is UpdateTransactionSuccess) {
                                              return TransactionCard(
                                                transaction:
                                                    state.updatedTransaction,
                                              );
                                            }
                                            return TransactionCard(
                                              transaction: transaction,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildSaleItemValue(
                                label: 'الكمية: ',
                                value:
                                    '${formatDouble(widget.transactionItem.quantity)} ${MeasurementUnit.toArabic(widget.item.unit.name)}',
                              ),
                              _buildSaleItemValue(
                                label: 'سعر المبيع: ',
                                value:
                                    '${formatDouble(widget.transactionItem.quantity * widget.transactionItem.sellingPrice)} ل.س',
                              ),
                              _buildSaleItemValue(
                                label: 'سعر الشراء: ',
                                value:
                                    '${formatDouble(widget.transactionItem.quantity * widget.transactionItem.purchasePrice)} ل.س',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text(
              'ليس لديك مبيعات بعد!',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 20),
            ),
          );
        }
      },
    );
  }

  Widget _buildSaleItemValue({required String label, required String value}) {
    const double fontSize = 18;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        textDirection: TextDirection.rtl,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: fontSize,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
