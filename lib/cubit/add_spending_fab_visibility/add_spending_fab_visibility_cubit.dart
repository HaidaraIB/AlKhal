import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'add_spending_fab_visibility_state.dart';

class AddSpendingFabVisibilityCubit
    extends Cubit<AddSpendingFabVisibilityState> {
  bool isVisible = true;

  AddSpendingFabVisibilityCubit()
      : super(
          const AddSpendingFabVisibilityInitial(
            isVisible: true,
          ),
        );
  void listenToScrolling(ScrollController transactionsScrollController) {
    transactionsScrollController.addListener(
      () {
        if (transactionsScrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (isVisible) {
            isVisible = false;
            emit(AddSpendingFabInvisible(isVisible: isVisible));
          }
        } else if (transactionsScrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!isVisible) {
            isVisible = true;
            emit(AddSpendingFabVisible(isVisible: isVisible));
          }
        }
      },
    );
  }
}
