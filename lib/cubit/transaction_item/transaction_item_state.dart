part of 'transaction_item_cubit.dart';

@immutable
sealed class TransactionItemState {
  final List<Model> transactionItems;
  const TransactionItemState({required this.transactionItems});
}

final class TransactionItemInitial extends TransactionItemState {
  const TransactionItemInitial({required super.transactionItems});
}

final class TransactionItemOperationFailed extends TransactionItemState {
  final String err;
  const TransactionItemOperationFailed({
    required super.transactionItems,
    required this.err,
  });
}

final class AddTransactionItemSuccess extends TransactionItemState {
  const AddTransactionItemSuccess({required super.transactionItems});
}

final class AddTransactionItemFail extends TransactionItemOperationFailed {
  const AddTransactionItemFail({
    required super.transactionItems,
    required super.err,
  });
}

final class LoadingTransactionItems extends TransactionItemState {
  const LoadingTransactionItems({required super.transactionItems});
}

final class LoadingTransactionItemsFailed
    extends TransactionItemOperationFailed {
  const LoadingTransactionItemsFailed({
    required super.transactionItems,
    required super.err,
  });
}

final class TransactionItemsLoaded extends TransactionItemState {
  const TransactionItemsLoaded({required super.transactionItems});
}
