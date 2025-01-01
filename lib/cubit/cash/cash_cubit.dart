import 'package:alkhal/services/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'cash_state.dart';

class CashCubit extends Cubit<CashState> {
  double cash = 0;
  double profit = 0;
  double bills = 0;
  double remainders = 0;
  double spendings = 0;
  double discounts = 0;
  CashCubit()
      : super(const CashInitial(
          cash: 0,
          profit: 0,
          bills: 0,
          remainders: 0,
          spendings: 0,
          discounts: 0,
        ));

  Future computeCash(DateTime startDate, DateTime endDate) async {
    emit(LoadingCash());
    try {
      await DatabaseHelper.computeCash(startDate, endDate).then((res) {
        cash = res['cash'] ?? 0;
        profit = res['profit'] ?? 0;
        bills = res['bills'] ?? 0;
        remainders = res['remainders'] ?? 0;
        spendings = res['spendings'] ?? 0;
        discounts = res['discounts'] ?? 0;
      });
      emit(CashRefreshed(
        cash: cash,
        profit: profit,
        bills: bills,
        remainders: remainders,
        spendings: spendings,
        discounts: discounts,
      ));
    } catch (e) {
      emit(CashRefreshingFailed(err: e.toString()));
    }
  }

  void popSettingsScreen() async {
    emit(SettingsScreenPopped());
  }
}
