import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/screens/transaction_items_screen.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Banner(
          location: BannerLocation.topStart,
          message: "",
          color: transaction.isSale == 1 ? Colors.green : Colors.red,
          child: Column(
            children: [
              Center(
                child: Text(
                  transaction.isSale == 1 ? "مبيع" : "شراء",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                arDateTimeFormat.format(
                  DateTime.parse(transaction.transactionDate),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (newContext) {
                            return BlocProvider.value(
                              value: BlocProvider.of<TransactionItemCubit>(
                                  context),
                              child: Scaffold(
                                appBar: AppBar(
                                  title: const Text('تفاصيل فاتورة'),
                                  centerTitle: true,
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
                  _buildTransactionDetails(),
                ],
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
        style: const TextStyle(fontSize: 20, color: Colors.black),
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
          const TextSpan(text: " ل.س"),
        ],
      ),
    );
  }
}