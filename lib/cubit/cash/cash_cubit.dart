import 'package:alkhal/services/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'cash_state.dart';

class CashCubit extends Cubit<CashState> {
  double cash = 0;
  double profit = 0;
  double bills = 0;
  double reminders = 0;
  CashCubit()
      : super(const CashInitial(
          cash: 0,
          profit: 0,
          bills: 0,
          reminders: 0,
        ));

  Future computeCash(DateTime startDate, DateTime endDate) async {
    emit(LoadingCash(
      cash: cash,
      profit: profit,
      bills: bills,
      reminders: reminders,
    ));
    try {
      await DatabaseHelper.computeCash(startDate, endDate).then((res) {
        cash = res['cash'] ?? 0;
        profit = res['profit'] ?? 0;
        bills = res['bills'] ?? 0;
        reminders = res['reminders'] ?? 0;
      });
      emit(CashRefreshed(
        cash: cash,
        profit: profit,
        bills: bills,
        reminders: reminders,
      ));
    } catch (e) {
      emit(CashRefreshingFailed(
        cash: cash,
        profit: profit,
        bills: bills,
        reminders: reminders,
        err: e.toString(),
      ));
    }
  }
}
