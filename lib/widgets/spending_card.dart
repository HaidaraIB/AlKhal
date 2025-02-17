import 'package:alkhal/cubit/spending/spending_cubit.dart';
import 'package:alkhal/models/spending.dart';
import 'package:alkhal/models/spending_status.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpendingCard extends StatefulWidget {
  final Spending spending;
  const SpendingCard({
    super.key,
    required this.spending,
  });

  @override
  State<SpendingCard> createState() => _SpendingCardState();
}

class _SpendingCardState extends State<SpendingCard> {
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
        child: _buildSpendingCardContent(),
      ),
    );
  }

  Column _buildSpendingCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            arDateTimeFormat.format(
              DateTime.parse(widget.spending.spendingDate),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.deepPurple,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                widget.spending.status == SpendingStatus.active.value
                    ? IconButton(
                        onPressed: () async {
                          await BlocProvider.of<SpendingCubit>(context)
                              .cancelSpending(widget.spending);
                        },
                        icon: const Icon(Icons.cancel_outlined),
                      )
                    : const SizedBox(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSpendingDetails(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    'ملاحظات: ${widget.spending.notes}',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpendingDetails() {
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        text: 'المبلغ: ',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black87,
          decoration: widget.spending.status == SpendingStatus.canceled.value
              ? TextDecoration.lineThrough
              : null,
        ),
        children: <TextSpan>[
          TextSpan(
            text: formatDouble(widget.spending.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration:
                  widget.spending.status == SpendingStatus.canceled.value
                      ? TextDecoration.lineThrough
                      : null,
            ),
          ),
          const TextSpan(text: " ل.س"),
        ],
      ),
    );
  }
}
