import 'package:alkhal/cubit/add_transaction_fab_visibility/add_transaction_fab_visibility_cubit.dart';
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
  final ScrollController _transactionsScrollController = ScrollController();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    BlocProvider.of<TransactionCubit>(context).loadTransactions();
    context
        .read<AddTransactionFabVisibilityCubit>()
        .listenToScrolling(_transactionsScrollController);
  }

  @override
  void dispose() {
    _transactionsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is LoadingTransactions) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          );
        } else if (state is TransactionLoadingFailed) {
          return buildErrorWidget(state.err);
        } else if (state.transactions.isNotEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: BlocBuilder<AddTransactionFabVisibilityCubit,
                AddTransactionFabVisibilityState>(
              builder: (context, newState) {
                return Visibility(
                  visible: newState.isVisible,
                  child: const AddTransactionFAB(),
                );
              },
            ),
            body: Column(
              children: [
                const SizedBox(height: 10),
                _buildDatePickerTextButton(state.dateFilter),
                const SizedBox(height: 10),
                _buildFilterRow(state),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context
                          .read<TransactionCubit>()
                          .refreshTransactionsCash();
                    },
                    child: ListView.builder(
                      controller: _transactionsScrollController,
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        return TransactionCard(
                          transaction: state.transactions[index] as Transaction,
                        );
                      },
                    ),
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
                _buildFilterRow(state),
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
    return ElevatedButton(
      onPressed: () => _selectDate(context, dateFilter),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        DateFormat("EEEE d MMMM y", "ar_SA").format(DateTime.parse(dateFilter)),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFilterRow(TransactionState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        TransactionFilterDropDown(filter: state.filter),
      ],
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
            .filterTransactions(selectedDate.toString());
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
            context.read<TransactionCubit>().setFilter(filter!),
      ),
    );
  }
}
