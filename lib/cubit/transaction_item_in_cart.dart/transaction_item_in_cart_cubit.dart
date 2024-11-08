import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'transaction_item_in_cart_state.dart';

class TransactionItemInCartCubit extends Cubit<TransactionItemInCartState> {
  List<Map> transactionItemMaps = [
    {
      "item": null,
      "item_id": 0,
      "category_id": 0,
      "quantity": 0.0,
      "price": 0.0,
    }
  ];
  TransactionItemInCartCubit()
      : super(const TransactionItemInCartInitial(transactionItemsInCart: [
          {
            "item": null,
            "item_id": 0,
            "category_id": 0,
            "quantity": 0.0,
            "price": 0.0,
          }
        ]));
  void addTransactionItemToCart(Map transactionItem) {
    try {
      transactionItemMaps.add(transactionItem);
      emit(AddTransactionItemMapSuccess(
          transactionItemsInCart: transactionItemMaps));
    } catch (e) {
      emit(AddTransactionItemMapFail(
        transactionItemsInCart: transactionItemMaps,
        err: e.toString(),
      ));
    }
  }

  void removeTransactionItemFromCart(Map transactionItemMap) {
    try {
      transactionItemMaps.remove(transactionItemMap);
      emit(RemoveTransactionItemMapSuccess(
          transactionItemsInCart: transactionItemMaps));
    } catch (e) {
      emit(RemoveTransactionItemMapFail(
        transactionItemsInCart: transactionItemMaps,
        err: e.toString(),
      ));
    }
  }
}
