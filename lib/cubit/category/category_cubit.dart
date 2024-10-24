import 'package:alkhal/models/category.dart';
import 'package:alkhal/models/model.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  List<Model> categories = [];

  CategoryCubit() : super(const CategoryInitial(categories: []));
  void loadCategories() async {
    emit(const LoadingCategories(categories: []));
    try {
      await DatabaseHelper.getAll(Category.tableName, "Category").then(
        (value) {
          categories = value;
        },
      );
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(const LoadingCategoriesFailed(categories: []));
    }
  }
}
