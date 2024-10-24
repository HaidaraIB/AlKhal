import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/widgets/add_transaction_fab.dart';
import 'package:alkhal/widgets/transaction_card.dart';
import 'package:alkhal/widgets/transaction_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TransactionCubit>(context).loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is LoadingTransactions) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        } else if (state is TransactionLoadingFailed) {
          return const Center(
            child: Text(
              "Something went wrong!",
              style: TextStyle(fontSize: 20),
            ),
          );
        } else if (state.transactions.isNotEmpty) {
          return Scaffold(
            floatingActionButton: const AddTransactionFAB(),
            body: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 100),
                    TransactionFilterDropDown(filter: state.filter),
                    const SizedBox(width: 100),
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
            floatingActionButton: const AddTransactionFAB(),
            body: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 100),
                    TransactionFilterDropDown(filter: state.filter),
                    const SizedBox(width: 100),
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
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.inversePrimary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          hintText: 'Select an item',
          hintStyle: TextStyle(color: Colors.purple[300]),
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
