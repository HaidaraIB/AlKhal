import 'package:alkhal/models/model.dart';
import 'package:alkhal/models/transaction_item.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'transaction_item_state.dart';

class TransactionItemCubit extends Cubit<TransactionItemState> {
  List<Model> transactionItems = [];
  TransactionItemCubit()
      : super(const TransactionItemInitial(transactionItems: []));

  void loadItems(int transactionId) async {
    emit(LoadingTransactionItems(transactionItems: transactionItems));
    try {
      await DatabaseHelper.getAll(
        TransactionItem.tableName,
        "TransactionItem",
        "transaction_id = ?",
        [transactionId],
      ).then(
        (value) => transactionItems = value,
      );
      emit(TransactionItemsLoaded(transactionItems: transactionItems));
    } catch (e) {
      emit(LoadingTransactionItemsFailed(
        transactionItems: transactionItems,
        err: e.toString(),
      ));
    }
  }

  void addTransactionItem(TransactionItem transactionItem) async {
    try {
      int? transactionItemId = await DatabaseHelper.insert(
          TransactionItem.tableName, transactionItem);
      transactionItem.id = transactionItemId;
      transactionItems.add(transactionItem);
      transactionItems.sort((a, b) => (a as TransactionItem)
          .itemId
          .compareTo((b as TransactionItem).itemId));
      emit(AddTransactionItemSuccess(transactionItems: transactionItems));
    } catch (e) {
      emit(AddTransactionItemFail(
        transactionItems: transactionItems,
        err: e.toString(),
      ));
    }
  }
}
