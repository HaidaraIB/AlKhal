import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/widgets/transaction_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  List<Model> transactions = [];
  TransactionFilter filter = TransactionFilter.all;

  TransactionCubit()
      : super(const TransactionInitial(
          transactions: [],
          filter: TransactionFilter.all,
        ));

  Future<TransactionFilter> getFilter() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    filter = TransactionFilter.values.firstWhere(
      (f) => f.toString() == sharedPreferences.getString('filter'),
      orElse: () => TransactionFilter.all,
    );
    return filter;
  }

  void loadTransactions() async {
    emit(LoadingTransactions(transactions: const [], filter: filter));
    try {
      await DatabaseHelper.getAll(Transaction.tableName, "Transaction").then(
        (value) {
          transactions = value;
        },
      );
      await getFilter();
      emit(TransactionsLoaded(
        transactions: transactions.where((t) {
          t = (t as Transaction);
          return t.isSale &&
                  [TransactionFilter.all, TransactionFilter.sell]
                      .contains(filter) ||
              !t.isSale &&
                  [TransactionFilter.all, TransactionFilter.buy]
                      .contains(filter);
        }).toList(),
        filter: filter,
      ));
    } catch (e) {
      emit(LoadingTransactions(
        transactions: const [],
        filter: filter,
      ));
    }
  }

  Future<int?> addTransaction(Transaction transaction) async {
    try {
      int? transactionId =
          await DatabaseHelper.insert(Transaction.tableName, transaction);
      transactions.add(transaction);
      transactions.sort((a, b) => DateTime.parse((a as Transaction).date)
          .compareTo(DateTime.parse((b as Transaction).date)));
      await getFilter();
      emit(AddTransactionSuccess(
        transactions: transactions,
        filter: filter,
      ));
      return transactionId;
    } catch (e) {
      emit(AddTransactionFail(
        transactions: transactions,
        filter: filter,
      ));
      return -1;
    }
  }

  void setFilter(TransactionFilter f) async {
    filter = f;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('filter', filter.toString());
    emit(
      TransactionsFiltered(filter: filter, transactions: transactions),
    );
  }
}
