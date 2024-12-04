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

  Future loadItems({int? transactionId, int? itemId}) async {
    emit(const LoadingTransactionItems(transactionItems: []));
    try {
      await DatabaseHelper.getAll(
        TransactionItem.tableName,
        "TransactionItem",
        where: transactionId != null ? "transaction_id = ?" : "item_id = ?",
        whereArgs: [transactionId ?? itemId],
        orderBy: "transaction_id DESC",
      ).then(
        (value) => transactionItems = value,
      );
      emit(TransactionItemsLoaded(transactionItems: transactionItems));
    } catch (e) {
      emit(LoadingTransactionItemsFailed(
        transactionItems: const [],
        err: e.toString(),
      ));
    }
  }
}
