import 'package:alkhal/cubit/add_spending_fab_visibility/add_spending_fab_visibility_cubit.dart';
import 'package:alkhal/cubit/cash/cash_cubit.dart';
import 'package:alkhal/cubit/spending/spending_cubit.dart';
import 'package:alkhal/models/spending.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/widgets/add_spending_fab.dart';
import 'package:alkhal/widgets/spendings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpendingsScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Widget Function(String, double) buildNumberWidget;
  const SpendingsScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.buildNumberWidget,
  });

  @override
  State<SpendingsScreen> createState() => _SpendingsScreenState();
}

class _SpendingsScreenState extends State<SpendingsScreen> {
  ScrollController spendingsScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    context
        .read<AddSpendingFabVisibilityCubit>()
        .listenToScrolling(spendingsScrollController);
    context.read<SpendingCubit>().loadSpendings();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          BlocProvider.of<CashCubit>(context)
              .computeCash(widget.startDate, widget.endDate),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("المصروف"),
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<SpendingCubit, SpendingState>(
          builder: (context, state) {
            if (state is LoadingSpendings) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              );
            } else if (state is LoadingSpendingsFailed) {
              return buildErrorWidget(state.err);
            } else if (state is SpendingsList && state.spendings.isNotEmpty) {
              return Column(
                children: [
                  widget.buildNumberWidget(
                    'الإجمالي',
                    state.spendings
                        .fold(0, (sum, t) => sum + (t as Spending).amount),
                  ),
                  Expanded(
                    child: Spendings(
                      spendings: state.spendings,
                      spendingsScrollController: spendingsScrollController,
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text(
                  "لا مصاريف بعد!",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              );
            }
          },
        ),
        floatingActionButton: BlocBuilder<AddSpendingFabVisibilityCubit,
            AddSpendingFabVisibilityState>(
          bloc: BlocProvider.of<AddSpendingFabVisibilityCubit>(context),
          builder: (context, newState) {
            return Visibility(
              visible: newState.isVisible,
              child: const AddSpendingFab(),
            );
          },
        ),
      ),
    );
  }
}
