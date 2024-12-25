part of 'transaction_item_cubit.dart';

@immutable
sealed class TransactionItemState {
  const TransactionItemState();
}

final class TransactionItemList extends TransactionItemState {
  final List<Model> transactionItems;
  const TransactionItemList({required this.transactionItems});
}

final class TransactionItemInitial extends TransactionItemList {
  const TransactionItemInitial({required super.transactionItems});
}

final class TransactionItemOperationFailed extends TransactionItemState {
  final String err;
  const TransactionItemOperationFailed({
    required this.err,
  });
}

final class LoadingTransactionItems extends TransactionItemList {
  const LoadingTransactionItems({required super.transactionItems});
}

final class LoadingTransactionItemsFailed
    extends TransactionItemOperationFailed {
  const LoadingTransactionItemsFailed({
    required super.err,
  });
}

final class TransactionItemsLoaded extends TransactionItemList {
  const TransactionItemsLoaded({required super.transactionItems});
}
