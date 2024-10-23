import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  List<Model> items = [];

  ItemCubit() : super(const ItemInitial(items: []));
  void loadItems() async {
    emit(const LoadingItems(items: []));
    try {
      await DatabaseHelper.getAll(Item.tableName, "Item").then(
        (value) {
          items = value;
        },
      );
      items.sort((a, b) => (a as Item).name.compareTo((b as Item).name));
      emit(ItemsLoaded(items: items));
    } catch (e) {
      emit(LoadingItemsFailed(items: items));
    }
  }

  void addItem(Item item) async {
    try {
      int? itemId = await DatabaseHelper.insert(Item.tableName, item);
      item.id = itemId;
      items.add(item);
      items.sort((a, b) => (a as Item).name.compareTo((b as Item).name));
      emit(AddItemSuccess(items: items));
    } catch (e) {
      emit(AddItemFail(items: items));
    }
  }

  void updateItem(Item item) async {
    try {
      await DatabaseHelper.update(Item.tableName, item);
      items[items.indexWhere((i) => item.id == i.id)] = item;
      items.sort((a, b) => (a as Item).name.compareTo((b as Item).name));
      emit(UpdateItemSuccess(items: items));
    } catch (e) {
      emit(UpdateItemFail(items: items));
    }
  }

  void deleteItem(int itemId) async {
    try {
      await DatabaseHelper.delete(Item.tableName, itemId);
      items.removeAt(items.indexWhere((i) => itemId == i.id));
      emit(DeleteItemSuccess(items: items));
    } catch (e) {
      emit(DeleteItemFail(items: items));
    }
  }
}
