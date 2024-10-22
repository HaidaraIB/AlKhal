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
  Widget build(BuildContext context) {
    BlocProvider.of<TransactionCubit>(context).loadTransactions();
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is LoadingTransactions) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (state.transactions.isNotEmpty) {
          return Scaffold(
            floatingActionButton: const AddTransactionFAB(),
            body: Column(
              children: [
                DropdownButton<TransactionFilter>(
                  value: state.filter ?? TransactionFilter.all,
                  items: TransactionFilter.values
                      .map((filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(filter.name),
                          ))
                      .toList(),
                  onChanged: (filter) =>
                      context.read<TransactionCubit>().setFilter(filter!),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.transactions.length,
                    itemBuilder: (BuildContext context, int index) {
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
          return const Scaffold(
            floatingActionButton: AddTransactionFAB(),
            body: Center(
              child: Text("لا فواتير بعد"),
            ),
          );
        }
      },
    );
  }
}
