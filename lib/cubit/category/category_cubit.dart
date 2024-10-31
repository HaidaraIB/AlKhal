import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  List<Model> categories = [];

  CategoryCubit() : super(const CategoryInitial(categories: []));

  Future _loadCategories() async {
    await DatabaseHelper.getAll(Category.tableName, "Category").then(
      (value) {
        categories = value;
      },
    );
  }

  void loadCategories() async {
    emit(const LoadingCategories(categories: []));
    try {
      await _loadCategories();
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(const LoadingCategoriesFailed(categories: []));
    }
  }

  void addCategory(Category category) async {
    try {
      await DatabaseHelper.insert(Category.tableName, category);
      await _loadCategories();
      emit(AddCategorySuccess(categories: categories));
    } catch (e) {
      emit(const AddCategoryFail(categories: []));
    }
  }

  void updateCategory(Category category) async {
    try {
      await DatabaseHelper.update(Category.tableName, category);
      await _loadCategories();
      emit(UpdateCategorySuccess(categories: categories));
    } catch (e) {
      emit(const UpdateCategoryFail(categories: []));
    }
  }

  void deleteCategory(int categoryId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? f = sharedPreferences.getString("items_filter");
      if (f == null) {
        sharedPreferences.setString("items_filter", "all");
      }
      await DatabaseHelper.delete(Category.tableName, categoryId);
      await _loadCategories();
      emit(DeleteCategorySuccess(categories: categories));
    } catch (e) {
      emit(DeleteCategoryFail(categories: categories));
    }
  }
}
