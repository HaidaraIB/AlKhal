import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'add_item_fab_visibility_state.dart';

class AddItemFabVisibilityCubit extends Cubit<AddItemFabVisibilityState> {
  bool isVisible = true;
  AddItemFabVisibilityCubit()
      : super(const AddItemFabVisibilityInitial(isVisible: true));

  void listenToScrolling(ScrollController itemsScrollController) {
    itemsScrollController.addListener(() {
      if (itemsScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isVisible) {
          isVisible = false;
          emit(AddItemFabInvisible(isVisible: isVisible));
        }
      } else if (itemsScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!isVisible) {
          isVisible = true;
          emit(AddItemFabVisible(isVisible: isVisible));
        }
      }
    });
  }
}
