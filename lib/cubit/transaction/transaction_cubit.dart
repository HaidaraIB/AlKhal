import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction.dart';
import 'package:alkhal/models/transaction_item.dart';
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

  Future _loadTransactions() async {
    await getFilter();
    await DatabaseHelper.getAll(
      Transaction.tableName,
      "Transaction",
      where: "date(transaction_date) = ?",
      whereArgs: [DateFormat(dateFormat).format(DateTime.parse(dateFilter))],
      orderBy: "transaction_date DESC",
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

  Future loadTransactions([String? cond]) async {
    emit(
      const LoadingTransactions(),
    );
    try {
      if (cond == null) {
        await _loadTransactions();
      } else {
        await DatabaseHelper.getAll(
          Transaction.tableName,
          "Transaction",
          where: cond,
          orderBy: "transaction_date DESC",
        ).then(
          (value) {
            transactions = value;
          },
        );
      }
      emit(TransactionsLoaded(
        transactions: transactions,
        filter: filter,
        dateFilter: dateFilter,
      ));
    } catch (e) {
      emit(TransactionLoadingFailed(
        err: e.toString(),
      ));
    }
  }

  Future<bool> addTransaction(
    Transaction transaction,
    List<TransactionItem> transactionItems,
    List<Item> itemsToUpdate,
  ) async {
    try {
      await Transaction.addTransaction(
        transaction,
        transactionItems,
        itemsToUpdate,
      );
      await _loadTransactions();
      emit(AddTransactionSuccess(
        transactions: transactions,
        filter: filter,
        dateFilter: dateFilter,
      ));
      return true;
    } catch (e) {
      emit(AddTransactionFail(
        err: e.toString(),
      ));
      return false;
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

  void filterTransactions(String d) async {
    dateFilter = d;
    await _loadTransactions();
    emit(
      TransactionsFiltered(
        filter: filter,
        transactions: transactions,
        dateFilter: dateFilter,
      ),
    );
  }

  Future refreshTransactionsCash() async {
    try {
      for (Model transaction in transactions) {
        await TransactionItem.computeTransactionCash(
            transaction as Transaction);
      }
      emit(TransactionCashRefreshed(
        transactions: transactions,
        filter: filter,
        dateFilter: dateFilter,
      ));
    } catch (e) {
      emit(TransactionCashRefreshingFailed(
        err: e.toString(),
      ));
    }
  }

  Future updateTransaction(Transaction newTransaction) async {
    try {
      await DatabaseHelper.update(
        Transaction.tableName,
        newTransaction,
      );
      try {
        transactions[transactions.indexOf(transactions.firstWhere(
          (t) => t.id == newTransaction.id,
        ))] = newTransaction;
      } catch (e) {
        // Updating a transaction out of transacions list
      }
      emit(UpdateTransactionSuccess(
        updatedTransaction: newTransaction,
        transactions: transactions,
        dateFilter: dateFilter,
        filter: filter,
      ));
    } catch (e) {
      emit(UpdateTransactionsFailed(
        err: e.toString(),
      ));
    }
  }
}
