import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/widgets/transaction_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionFilterDropDown extends StatelessWidget {
  const TransactionFilterDropDown({
    super.key,
    required this.filter,
  });

  final TransactionFilter? filter;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<TransactionFilter>(
        isExpanded: true,
        decoration: InputDecoration(
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        elevation: 3,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        value: filter ?? TransactionFilter.all,
        items: TransactionFilter.values.map((filter) {
          return DropdownMenuItem(
            value: filter,
            child: Text(TransactionFilter.toArabic(filter.name)),
          );
        }).toList(),
        onChanged: (filter) =>
            BlocProvider.of<TransactionCubit>(context).setFilter(filter!),
      ),
    );
  }
}
