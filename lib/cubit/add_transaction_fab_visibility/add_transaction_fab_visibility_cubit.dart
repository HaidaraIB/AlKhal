import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'add_transaction_fab_visibility_state.dart';

class AddTransactionFabVisibilityCubit
    extends Cubit<AddTransactionFabVisibilityState> {
  bool isVisible = true;
  AddTransactionFabVisibilityCubit()
      : super(const AddTransactionFabVisibilityInitial(isVisible: true));

  void listenToScrolling(ScrollController transactionsScrollController) {
    transactionsScrollController.addListener(() {
      if (transactionsScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isVisible) {
          isVisible = false;
          emit(AddTransactionFabInvisible(isVisible: isVisible));
        }
      } else if (transactionsScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!isVisible) {
          isVisible = true;
          emit(AddTransactionFabVisible(isVisible: isVisible));
        }
      }
    });
  }
}
