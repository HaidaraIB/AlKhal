import 'package:alkhal/cubit/cash/cash_cubit.dart';
import 'package:alkhal/cubit/transaction/transaction_cubit.dart';
import 'package:alkhal/cubit/transaction_item/transaction_item_cubit.dart';
import 'package:alkhal/services/db_syncer.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:alkhal/widgets/transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

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
    BlocProvider.of<CashCubit>(context).computeCash(startDate, endDate);
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
                      _buildDateRangeButton(context),
                      const SizedBox(height: 20),
                      _buildNumberWidgets(state),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                BlocProvider.of<CashCubit>(context)
                    .computeCash(startDate, endDate);
              },
              child: const Icon(Icons.refresh),
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

  Widget _buildDateRangeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _selectDateRange(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'من: ${intl.DateFormat("EEE d MMM y", "ar_SA").format(startDate)}\nإلى: ${intl.DateFormat("EEE d MMM y", "ar_SA").format(endDate)}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNumberWidgets(CashRefreshed state) {
    return Column(
      children: [
        _buildNumberWidget('كاش', state.cash),
        const Divider(),
        _buildNumberWidget('ربح', state.profit),
        const Divider(),
        _buildNumberWidget('فواتير', state.bills),
        const Divider(),
        GestureDetector(
          child: _buildNumberWidget('ديون', state.remainders),
          onTap: () async {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (navContext) {
                  context
                      .read<TransactionCubit>()
                      .loadTransactions("remainder != 0");
                  final transactionCubit =
                      BlocProvider.of<TransactionCubit>(context);
                  final transactionItemCubit =
                      BlocProvider.of<TransactionItemCubit>(context);
                  return PopScope(
                    onPopInvokedWithResult: (didPop, result) =>
                        BlocProvider.of<CashCubit>(context)
                            .computeCash(startDate, endDate),
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text("فواتير الديون"),
                      ),
                      body: BlocBuilder<TransactionCubit, TransactionState>(
                        bloc: transactionCubit,
                        builder: (blocContext, state) {
                          if (state is LoadingTransactions) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.purple,
                              ),
                            );
                          } else if (state is TransactionLoadingFailed) {
                            return buildErrorWidget(state.err);
                          } else if (state.transactions.isNotEmpty) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider<TransactionCubit>.value(
                                  value: transactionCubit,
                                ),
                                BlocProvider<TransactionItemCubit>.value(
                                  value: transactionItemCubit,
                                ),
                              ],
                              child: Transactions(
                                transactions: state.transactions,
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
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNumberWidget(String label, double value) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: NumberWidget(label: label, value: value),
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

class NumberWidget extends StatelessWidget {
  final String label;
  final double value;

  const NumberWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 300),
          builder: (context, double val, child) {
            return Text(
              '${formatDouble(val)} ل.س',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.purple,
              ),
            );
          },
        ),
      ],
    );
  }
}
