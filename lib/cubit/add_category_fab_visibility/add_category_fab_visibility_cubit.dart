import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'add_category_fab_visibility_state.dart';

class AddCategoryFabVisibilityCubit
    extends Cubit<AddCategoryFabVisibilityState> {
  bool isVisible = true;
  AddCategoryFabVisibilityCubit()
      : super(const AddCategoryFabVisibilityInitial(isVisible: true));

  void listenToScrolling(ScrollController categoriesScrollController) {
    categoriesScrollController.addListener(() {
      if (categoriesScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isVisible) {
          isVisible = false;
          emit(AddCategoryFabInvisible(isVisible: isVisible));
        }
      } else if (categoriesScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!isVisible) {
          isVisible = true;
          emit(AddCategoryFabVisible(isVisible: isVisible));
        }
      }
    });
  }
}
