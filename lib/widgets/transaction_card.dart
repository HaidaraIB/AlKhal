import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/screens/transaction_items_screen.dart';
import 'package:alkhal/screens/update_transaction_screen.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Banner(
          location: BannerLocation.topStart,
          message: transaction.isSale == 1 ? "مبيع" : "شراء",
          color: transaction.isSale == 1 ? Colors.green : Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  arDateTimeFormat.format(
                    DateTime.parse(transaction.transactionDate),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.deepPurple,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          final transactionItemCubit =
                              BlocProvider.of<TransactionItemCubit>(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (newContext) {
                                return BlocProvider<TransactionItemCubit>.value(
                                  value: transactionItemCubit,
                                  child: Scaffold(
                                    appBar: AppBar(
                                      title: const Text('تفاصيل فاتورة'),
                                    ),
                                    body: TransactionItems(
                                      transactionId: transaction.id!,
                                      isSale: transaction.isSale == 1,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.info),
                      ),
                      IconButton(
                        onPressed: () {
                          final transactionCubit =
                              BlocProvider.of<TransactionCubit>(context);
                          final transactionItemCubit =
                              BlocProvider.of<TransactionItemCubit>(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (newContext) {
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider<TransactionCubit>.value(
                                      value: transactionCubit,
                                    ),
                                    BlocProvider<TransactionItemCubit>.value(
                                      value: transactionItemCubit,
                                    ),
                                  ],
                                  child: UpdateTransactionScreen(
                                    transaction: transaction,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                      )
                    ],
                  ),
                  _buildTransactionDetails(),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  'ملاحظات: ${transaction.notes}',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        text: 'السعر الإجمالي: ',
        style: const TextStyle(fontSize: 18, color: Colors.black87),
        children: <TextSpan>[
          TextSpan(
            text: formatDouble(transaction.totalPrice),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: " ل.س\n"),
          const TextSpan(text: 'الربح: '),
          TextSpan(
            text: formatDouble(transaction.totalProfit),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: " ل.س\n"),
          const TextSpan(text: 'الحسم: '),
          TextSpan(
            text: formatDouble(transaction.discount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: " ل.س\n"),
          const TextSpan(text: 'الباقي: '),
          TextSpan(
            text: formatDouble(transaction.remainder),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: " ل.س"),
        ],
      ),
    );
  }
}
