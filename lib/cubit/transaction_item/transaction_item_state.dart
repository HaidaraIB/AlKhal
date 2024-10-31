part of 'transaction_item_cubit.dart';

@immutable
sealed class TransactionItemState {
  final List<Model> transactionItems;
  const TransactionItemState({required this.transactionItems});
}

final class TransactionItemInitial extends TransactionItemState {
  const TransactionItemInitial({required super.transactionItems});
}

final class AddTransactionItemSuccess extends TransactionItemState {
  const AddTransactionItemSuccess({required super.transactionItems});
}

final class AddTransactionItemFail extends TransactionItemState {
  const AddTransactionItemFail({required super.transactionItems});
}

final class LoadingTransactionItems extends TransactionItemState {
  const LoadingTransactionItems({required super.transactionItems});
}

final class LoadingTransactionItemsFailed extends TransactionItemState {
  const LoadingTransactionItemsFailed({required super.transactionItems});
}

final class TransactionItemsLoaded extends TransactionItemState {
  const TransactionItemsLoaded({required super.transactionItems});
}
