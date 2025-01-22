import 'package:alkhal/cubit/add_spending_fab_visibility/add_spending_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/cash/cash_cubit.dart';
import 'package:alkhal/cubit/spending/spending_cubit.dart';
import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/screens/charts_screen.dart';
import 'package:alkhal/screens/spendings_screen.dart';
import 'package:alkhal/services/db_syncer.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:alkhal/widgets/transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen>
    with SingleTickerProviderStateMixin {
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    endDate = DateTime.now();
    context.read<CashCubit>().computeCash(startDate, endDate);
    DbSyncer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CashCubit, CashState>(
      bloc: BlocProvider.of<CashCubit>(context),
      listener: (context, state) {
        if (state is SettingsScreenPopped) {
          context.read<CashCubit>().computeCash(startDate, endDate);
        }
      },
      builder: (context, state) {
        if (state is CashRefreshingFailed) {
          return buildErrorWidget(state.err);
        } else if (state is CashRefreshed) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: () async {
                await BlocProvider.of<CashCubit>(context)
                    .computeCash(startDate, endDate);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      buildDateRangeButton(
                        context: context,
                        startDate: startDate,
                        endDate: endDate,
                        selectDateRange: _selectDateRange,
                      ),
                      const SizedBox(height: 20),
                      buildNumberWidgets(state),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.purple,
          ),
        );
      },
    );
  }

  Widget buildNumberWidgets(CashRefreshed state) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (newContext) {
                  return ChartsScreen(
                    cashData: {
                      "cash": state.cash,
                      "spendings": state.spendings,
                      "profit": state.profit,
                      "remainders": state.remainders,
                      "discounts": state.discounts,
                      "bills": state.bills,
                    },
                  );
                },
              ),
            );
          },
          child: buildNumberWidget('كاش', state.cash),
        ),
        const Divider(),
        buildNumberWidget('ربح', state.profit),
        const Divider(),
        buildNumberWidget('فواتير', state.bills),
        const Divider(),
        GestureDetector(
          child: buildNumberWidget('مصروف', state.spendings),
          onTap: () async {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (newContext) {
                  final cashCubit = BlocProvider.of<CashCubit>(context);
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => SpendingCubit(),
                      ),
                      BlocProvider(
                        create: (context) => AddSpendingFabVisibilityCubit(),
                      ),
                      BlocProvider.value(value: cashCubit)
                    ],
                    child: SpendingsScreen(
                      endDate: endDate,
                      startDate: startDate,
                    ),
                  );
                },
              ),
            );
          },
        ),
        const Divider(),
        GestureDetector(
          child: buildNumberWidget('ديون', state.remainders),
          onTap: () async {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (newContext) {
                  context
                      .read<TransactionCubit>()
                      .loadTransactions("remainder != 0");
                  final transactionCubit =
                      BlocProvider.of<TransactionCubit>(context);
                  final transactionItemCubit =
                      BlocProvider.of<TransactionItemCubit>(context);
                  return _buildRemaindersScreen(
                    transactionCubit,
                    transactionItemCubit,
                  );
                },
              ),
            );
          },
        ),
        const Divider(),
        buildNumberWidget('حسم', state.discounts),
      ],
    );
  }

  PopScope<Object> _buildRemaindersScreen(
    TransactionCubit transactionCubit,
    TransactionItemCubit transactionItemCubit,
  ) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          BlocProvider.of<CashCubit>(context).computeCash(startDate, endDate),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("فواتير الديون"),
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<TransactionCubit, TransactionState>(
          bloc: transactionCubit,
          builder: (transactionContext, transactionState) {
            if (transactionState is LoadingTransactions) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              );
            } else if (transactionState is TransactionLoadingFailed) {
              return buildErrorWidget(transactionState.err);
            } else if (transactionState is TransactionList) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<TransactionCubit>.value(
                    value: transactionCubit,
                  ),
                  BlocProvider<TransactionItemCubit>.value(
                    value: transactionItemCubit,
                  ),
                ],
                child: Column(
                  children: [
                    buildNumberWidget(
                      'الإجمالي',
                      transactionState.transactions.fold(
                          0, (sum, t) => sum + (t as Transaction).remainder),
                    ),
                    Expanded(
                      child: Transactions(
                        transactions: transactionState.transactions,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text(
                  "لا فواتير بديون بعد!",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
        BlocProvider.of<CashCubit>(context).computeCash(startDate, endDate);
      });
    }
  }
}
