import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/widgets/transaction_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  List<Model> transactions = [];
  TransactionFilter filter = TransactionFilter.all;
  String dateFilter = DateFormat("y-MM-d").format(DateTime.now());

  TransactionCubit()
      : super(TransactionInitial(
          transactions: const [],
          filter: TransactionFilter.all,
          dateFilter: DateFormat("y-MM-d").format(DateTime.now()),
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
        DateFormat("y-MM-d").format(DateTime.now());
    try {
      DateFormat("EEEE d MMMM y", "ar_SY").format(DateTime.parse(dateFilter));
    } catch (e) {
      dateFilter = DateFormat("y-MM-d").format(DateTime.now());
    }
    return dateFilter;
  }

  void loadTransactions() async {
    emit(LoadingTransactions(
      transactions: const [],
      filter: filter,
      dateFilter: dateFilter,
    ));
    try {
      await getFilter();
      await getDateFilter();
      await DatabaseHelper.getAll(
        Transaction.tableName,
        "Transaction",
        "date(transaction_date) = ?",
        [DateFormat("y-MM-d").format(DateTime.parse(dateFilter))],
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
      ));
    }
  }

  Future<int?> addTransaction(Transaction transaction) async {
    try {
      await getFilter();
      int? transactionId =
          await DatabaseHelper.insert(Transaction.tableName, transaction);
      loadTransactions();
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
      ));
      return -1;
    }
  }

  void setFilter(TransactionFilter f) async {
    filter = f;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('transaction_filter', filter.toString());
    loadTransactions();
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
    loadTransactions();
    emit(
      TransactionsFiltered(
        filter: filter,
        transactions: transactions,
        dateFilter: dateFilter,
      ),
    );
  }
}
