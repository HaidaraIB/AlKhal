import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/widgets/add_transaction_fab.dart';
import 'package:alkhal/widgets/transaction_card.dart';
import 'package:alkhal/widgets/transaction_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    BlocProvider.of<TransactionCubit>(context).loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is LoadingTransactions) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state is TransactionLoadingFailed) {
          return buildErrorWidget(state.err);
        } else if (state.transactions.isNotEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: const AddTransactionFAB(),
            body: Column(
              children: [
                const SizedBox(height: 10),
                _buildDatePickerTextButton(state.dateFilter),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TransactionFilterDropDown(filter: state.filter),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      return TransactionCard(
                        transaction: state.transactions[index] as Transaction,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: const AddTransactionFAB(),
            body: Column(
              children: [
                const SizedBox(height: 10),
                _buildDatePickerTextButton(state.dateFilter),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TransactionFilterDropDown(filter: state.filter),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: Text(
                      "!لا فواتير ${state.filter.name != 'all' ? '${TransactionFilter.toArabic(state.filter.name)} بعد' : 'بعد'}",
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDatePickerTextButton(String dateFilter) {
    return TextButton(
      onPressed: () => _selectDate(context, dateFilter),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      child: Text(
        DateFormat("EEEE d MMMM y", "ar_SA").format(DateTime.parse(dateFilter)),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, String initialDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(initialDate),
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        BlocProvider.of<TransactionCubit>(context)
            .setTransactionDateFilter(selectedDate.toString());
      });
    }
  }
}

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
          filled: true,
          fillColor: Theme.of(context).colorScheme.inversePrimary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        dropdownColor: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(10),
        value: filter ?? TransactionFilter.all,
        items: TransactionFilter.values.map((filter) {
          return DropdownMenuItem(
            value: filter,
            child: Text(TransactionFilter.toArabic(filter.name)),
          );
        }).toList(),
        onChanged: (filter) =>
            context.read<TransactionCubit>().setFilter(filter!),
      ),
    );
  }
}
