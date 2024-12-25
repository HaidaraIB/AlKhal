import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/item.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  List<Model> items = [];
  List<Model> categories = [];
  String filter = "all";
  String filterName = "عناصر";

  ItemCubit()
      : super(const ItemInitial(
          items: [],
          filter: 'all',
          categories: [],
          filterName: "عناصر",
        ));

  Future loadItems() async {
    emit(LoadingItems(
      items: const [],
      filter: filter,
      categories: const [],
      filterName: "عناصر",
    ));
    try {
      await _loadItems();
      emit(ItemsLoaded(
        items: items,
        filter: filter,
        categories: categories,
        filterName: filterName,
      ));
    } catch (e) {
      emit(LoadingItemsFailed(
        items: const [],
        filter: filter,
        categories: const [],
        filterName: "عناصر",
        err: e.toString(),
      ));
    }
  }

  void addItem(Item item) async {
    try {
      await DatabaseHelper.insert(Item.tableName, item);
      await _loadItems();
      emit(AddItemSuccess(
        items: items,
        filter: filter,
        categories: categories,
        filterName: filterName,
      ));
    } catch (e) {
      emit(AddItemFail(
        items: const [],
        filter: filter,
        categories: const [],
        filterName: "عناصر",
        err: e.toString(),
      ));
    }
  }

  Future updateItem(Item item) async {
    try {
      await DatabaseHelper.update(Item.tableName, item);
      await _loadItems();
      emit(UpdateItemSuccess(
        items: items,
        updatedItem: item,
        filter: filter,
        categories: categories,
        filterName: filterName,
      ));
    } catch (e) {
      emit(UpdateItemFail(
        items: const [],
        filter: filter,
        categories: const [],
        filterName: "عناصر",
        err: e.toString(),
      ));
    }
  }

  void deleteItem(int itemId) async {
    try {
      await DatabaseHelper.delete(Item.tableName, itemId);
      await _loadItems();
      emit(DeleteItemSuccess(
        items: items,
        filter: filter,
        categories: categories,
        filterName: filterName,
      ));
    } catch (e) {
      emit(DeleteItemFail(
        items: const [],
        filter: filter,
        categories: const [],
        filterName: "عناصر",
        err: e.toString(),
      ));
    }
  }

  void setFilter(String f) async {
    filter = f;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('items_filter', filter.toString());
    await _loadItems();
    emit(ItemsFiltered(
      filter: filter,
      items: items,
      categories: categories,
      filterName: filterName,
    ));
  }

  Future _loadItems() async {
    await getFilter();
    await DatabaseHelper.getAll(Item.tableName, "Item", orderBy: "name").then(
      (value) {
        items = value.where(
          (item) {
            if (int.tryParse(filter) != null) {
              return (item as Item).categoryId == int.tryParse(filter);
            } else {
              return true;
            }
          },
        ).toList();
      },
    );
    await DatabaseHelper.getAll(Category.tableName, "Category", orderBy: "name")
        .then(
      (value) {
        categories = value;
      },
    );
  }

  Future<String> getFilter() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? f = sharedPreferences.getString('items_filter');
    Category? category = await DatabaseHelper.getById(
            Category.tableName, "Category", int.tryParse(f ?? "all") ?? -1)
        as Category?;
    if (category == null) {
      filter = "all";
      filterName = "عناصر";
    } else {
      filter = f!;
      filterName = category.name;
    }
    return filter;
  }
}
