import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/spending.dart';
import 'package:alkhal/models/spending_state.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'spending_state.dart';

class SpendingCubit extends Cubit<SpendingState> {
  List<Model?> spendings = [];
  SpendingCubit() : super(SpendingInitial());

  Future loadSpendings() async {
    emit(LoadingSpendings());
    try {
      await _loadSpendings();
      emit(SpendingsLoaded(
        spendings: spendings,
      ));
    } catch (e) {
      emit(LoadingSpendingsFailed(
        err: e.toString(),
      ));
    }
  }

  void addSpending(Spending spending) async {
    try {
      await DatabaseHelper.insert(Spending.tableName, spending);
      await _loadSpendings();
      emit(AddSpendingSuccess(
        spendings: spendings,
      ));
    } catch (e) {
      emit(AddSpendingFail(
        err: e.toString(),
      ));
    }
  }

  Future cancelSpending(Spending spending) async {
    try {
      await DatabaseHelper.update(
        Spending.tableName,
        Spending(
          id: spending.id,
          amount: spending.amount,
          notes: spending.notes,
          spendingDate: spending.spendingDate,
          status: SpendingStatus.canceled.value,
        ),
      );
      await _loadSpendings();
      emit(CancelSpendingSuccess(
        spendings: spendings,
      ));
    } catch (e) {
      emit(CancelSpendingFail(
        err: e.toString(),
      ));
    }
  }

  Future _loadSpendings() async {
    await DatabaseHelper.getAll(
      Spending.tableName,
      "Spending",
      orderBy: "spending_date DESC",
    ).then(
      (value) {
        spendings = value;
      },
    );
  }
}
