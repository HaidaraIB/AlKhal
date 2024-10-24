import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/screens/transaction_items_screen.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

class TransactionCard extends StatefulWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.transaction.isSale == 1 ? "مبيع" : "شراء",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color.fromARGB(255, 133, 133, 133),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              intl.DateFormat()
                  .format(DateTime.parse(widget.transaction.transactionDate)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (newContext) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider<TransactionItemCubit>.value(
                                  value: BlocProvider.of(context),
                                ),
                              ],
                              child: Scaffold(
                                appBar: AppBar(
                                  title: const Text('تفاصيل فاتورة'),
                                  centerTitle: true,
                                ),
                                body: TransactionItems(
                                  transactionId: widget.transaction.id!,
                                  isSale: widget.transaction.isSale,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.info)),
                RichText(
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    text: "الحسم: ",
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: formatDouble(widget.transaction.discount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: " ل.س\n",
                      ),
                      const TextSpan(
                        text: 'السعر الإجمالي: ',
                      ),
                      TextSpan(
                        text: formatDouble(widget.transaction.totalPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: " ل.س",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
