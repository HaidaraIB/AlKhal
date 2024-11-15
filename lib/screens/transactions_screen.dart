import 'package:alkhal/cubit/add_transaction_fab_visibility/add_transaction_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/item/item_cubit.dart';
import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/widgets/add_transaction_fab.dart';
import 'package:alkhal/widgets/transaction_filter.dart';
import 'package:alkhal/widgets/transaction_filter_drop_down.dart';
import 'package:alkhal/widgets/transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ItemCubit(),
        ),
        BlocProvider(
          create: (context) => TransactionItemCubit(),
        ),
      ],
      child: BlocBuilder<TransactionCubit, TransactionState>(
        bloc: BlocProvider.of<TransactionCubit>(context),
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
              floatingActionButton: BlocBuilder<
                  AddTransactionFabVisibilityCubit,
                  AddTransactionFabVisibilityState>(
                bloc:
                    BlocProvider.of<AddTransactionFabVisibilityCubit>(context),
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
                  _buildFilterRow(state.filter),
                  const SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<TransactionCubit>()
                            .refreshTransactionsCash();
                      },
                      child: Transactions(
                        transactions: state.transactions,
                        transactionsScrollController:
                            _transactionsScrollController,
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
                  _buildFilterRow(state.filter),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: Text(
                        "لا فواتير ${state.filter.name != 'all' ? TransactionFilter.toArabic(state.filter.name) : ''} بعد!",
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
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
        intl.DateFormat("EEEE d MMMM y", "ar_SA")
            .format(DateTime.parse(dateFilter)),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFilterRow(TransactionFilter filter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        TransactionFilterDropDown(filter: filter),
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
