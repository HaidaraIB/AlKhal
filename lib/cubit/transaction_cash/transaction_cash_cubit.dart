import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'transaction_cash_state.dart';

class TransactionCashCubit extends Cubit<TransactionCashState> {
  TransactionCashCubit() : super(const TransactionCashInitial(cash: 0));

  void updateCash(double cash) async {
    emit(TransactionCashUpdated(cash: cash));
  }
}
