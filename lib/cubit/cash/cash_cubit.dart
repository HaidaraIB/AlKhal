import 'package:alkhal/services/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'cash_state.dart';

class CashCubit extends Cubit<CashState> {
  double cash = 0;
  double profit = 0;
  double bills = 0;
  CashCubit() : super(const CashInitial(cash: 0, profit: 0, bills: 0));

  void computeCash(DateTime d) async {
    emit(LoadingCash(cash: cash, profit: profit, bills: bills));
    try {
      await DatabaseHelper.computeCash(d).then((res) {
        cash = res['cash'] ?? 0;
        profit = res['profit'] ?? 0;
        bills = res['bills'] ?? 0;
      });
      emit(CashRefreshed(cash: cash, profit: profit, bills: bills));
    } catch (e) {
      emit(CashRefreshingFailed(
          cash: cash, profit: profit, bills: bills, err: e.toString()));
    }
  }
}
