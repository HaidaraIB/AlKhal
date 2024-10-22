import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});
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
                transaction.isSale ? "مبيع" : "شراء",
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
            intl.DateFormat().format(DateTime.parse(transaction.date)),
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
              IconButton(onPressed: () {}, icon: const Icon(Icons.info)),
              RichText(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  text: "الحسم: ",
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: formatDouble(transaction.discount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: " ل.س\n",
                    ),
                    const TextSpan(
                      text: 'السعر الإجمالي: ',
                    ),
                    TextSpan(
                      text: formatDouble(transaction.totalPrice),
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
    ));
  }
}
