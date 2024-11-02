import 'package:alkhal/models/item_history.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'item_history_state.dart';

class ItemHistoryCubit extends Cubit<ItemHistoryState> {
  List<Model> itemHistory = [];
  ItemHistoryCubit() : super(const ItemHistoryInitial(itemHistory: []));

  void loadHistory(int itemId) async {
    emit(const LoadingHistory(itemHistory: []));
    try {
      await DatabaseHelper.getAll(
        ItemHistory.tableName,
        "ItemHistory",
        "item_id = ?",
        [itemId],
      ).then((history) {
        itemHistory = history;
      });
      itemHistory.sort((a, b) => (a as ItemHistory)
          .updateDate
          .compareTo((b as ItemHistory).updateDate));
      emit(HistoryLoaded(itemHistory: itemHistory));
    } catch (e) {
      emit(LoadingHistoryFailed(itemHistory: const [], err: e.toString()));
    }
  }

  void addItemHistory(ItemHistory i) async {
    try {
      await DatabaseHelper.insert(ItemHistory.tableName, i);
      emit(AddItemHistorySuccess(itemHistory: itemHistory));
    } catch (e) {
      emit(AddItemHistoryFail(itemHistory: itemHistory));
    }
  }
}
