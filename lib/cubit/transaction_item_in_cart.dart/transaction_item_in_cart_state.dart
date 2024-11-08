part of 'transaction_item_in_cart_cubit.dart';

@immutable
sealed class TransactionItemInCartState {
  final List<Map> transactionItemsInCart;
  const TransactionItemInCartState({required this.transactionItemsInCart});
}

final class TransactionItemInCartInitial extends TransactionItemInCartState {
  const TransactionItemInCartInitial({required super.transactionItemsInCart});
}

final class TransactionItemInCartOperationFailed
    extends TransactionItemInCartState {
  final String err;
  const TransactionItemInCartOperationFailed({
    required super.transactionItemsInCart,
    required this.err,
  });
}

final class AddTransactionItemMapSuccess extends TransactionItemInCartState {
  const AddTransactionItemMapSuccess({required super.transactionItemsInCart});
}

final class AddTransactionItemMapFail
    extends TransactionItemInCartOperationFailed {
  const AddTransactionItemMapFail({
    required super.transactionItemsInCart,
    required super.err,
  });
}

final class RemoveTransactionItemMapSuccess extends TransactionItemInCartState {
  const RemoveTransactionItemMapSuccess({
    required super.transactionItemsInCart,
  });
}

final class RemoveTransactionItemMapFail
    extends TransactionItemInCartOperationFailed {
  const RemoveTransactionItemMapFail({
    required super.err,
    required super.transactionItemsInCart,
  });
}
