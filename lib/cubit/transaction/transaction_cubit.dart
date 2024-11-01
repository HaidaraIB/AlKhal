import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/constants.dart';
import 'package:alkhal/widgets/transaction_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  List<Model> transactions = [];
  TransactionFilter filter = TransactionFilter.all;
  String dateFilter = DateFormat(dateFormat).format(DateTime.now());

  TransactionCubit()
      : super(TransactionInitial(
          transactions: const [],
          filter: TransactionFilter.all,
          dateFilter: DateFormat(dateFormat).format(DateTime.now()),
        ));

  Future<TransactionFilter> getFilter() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    filter = TransactionFilter.values.firstWhere(
      (f) => f.toString() == sharedPreferences.getString('transaction_filter'),
      orElse: () => TransactionFilter.all,
    );
    return filter;
  }

  Future<String> getDateFilter() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    dateFilter = sharedPreferences.getString('transaction_date_filter') ??
        DateFormat(dateFormat).format(DateTime.now());

    return dateFilter;
  }

  Future _loadTransactions() async {
    await getFilter();
    await getDateFilter();
    await DatabaseHelper.getAll(
      Transaction.tableName,
      "Transaction",
      "date(transaction_date) = ?",
      [DateFormat(dateFormat).format(DateTime.parse(dateFilter))],
    ).then(
      (value) {
        transactions = value.where((t) {
          t = (t as Transaction);
          return t.isSale != 0 &&
                  [TransactionFilter.all, TransactionFilter.sell]
                      .contains(filter) ||
              t.isSale == 0 &&
                  [TransactionFilter.all, TransactionFilter.buy]
                      .contains(filter);
        }).toList();
      },
    );
  }

  Future loadTransactions() async {
    emit(LoadingTransactions(
      transactions: const [],
      filter: filter,
      dateFilter: dateFilter,
    ));
    try {
      await _loadTransactions();
      emit(TransactionsLoaded(
        transactions: transactions,
        filter: filter,
        dateFilter: dateFilter,
      ));
    } catch (e) {
      emit(TransactionLoadingFailed(
        transactions: const [],
        filter: filter,
        dateFilter: dateFilter,
        err: e.toString(),
      ));
    }
  }

  Future<int?> addTransaction(Transaction transaction) async {
    try {
      await getFilter();
      int? transactionId =
          await DatabaseHelper.insert(Transaction.tableName, transaction);
      await _loadTransactions();
      emit(AddTransactionSuccess(
        transactions: transactions,
        filter: filter,
        dateFilter: dateFilter,
      ));
      return transactionId;
    } catch (e) {
      emit(AddTransactionFail(
        transactions: const [],
        filter: filter,
        dateFilter: dateFilter,
        err: e.toString(),
      ));
      return -1;
    }
  }

  void setFilter(TransactionFilter f) async {
    filter = f;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('transaction_filter', filter.toString());
    await _loadTransactions();
    emit(
      TransactionsFiltered(
        filter: filter,
        transactions: transactions,
        dateFilter: dateFilter,
      ),
    );
  }

  void setTransactionDateFilter(String d) async {
    dateFilter = d;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('transaction_date_filter', dateFilter);
    await _loadTransactions();
    emit(
      TransactionsFiltered(
        filter: filter,
        transactions: transactions,
        dateFilter: dateFilter,
      ),
    );
  }
}
