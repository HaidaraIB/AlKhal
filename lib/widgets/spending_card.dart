import 'package:alkhal/models/spending.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';

class SpendingCard extends StatelessWidget {
  final Spending spending;
  const SpendingCard({
    super.key,
    required this.spending,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                arDateTimeFormat.format(
                  DateTime.parse(spending.spendingDate),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.deepPurple,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Column(
                //   children: [
                //     IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                //   ],
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSpendingDetails(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'ملاحظات: ${spending.notes}',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingDetails() {
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        text: 'المبلغ: ',
        style: const TextStyle(fontSize: 22, color: Colors.black87),
        children: <TextSpan>[
          TextSpan(
            text: formatDouble(spending.amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: " ل.س"),
        ],
      ),
    );
  }
}
