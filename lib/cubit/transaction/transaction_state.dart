part of 'transaction_cubit.dart';

@immutable
sealed class TransactionState {
  final List<Model> transactions;
  final TransactionFilter filter;
  const TransactionState({
    required this.transactions,
    required this.filter,
  });
}

final class TransactionInitial extends TransactionState {
  const TransactionInitial({
    required super.transactions,
    required super.filter,
  });
}

final class LoadingTransactions extends TransactionState {
  const LoadingTransactions({
    required super.transactions,
    required super.filter,
  });
}

final class TransactionsLoaded extends TransactionState {
  const TransactionsLoaded({
    required super.transactions,
    required super.filter,
  });
}

final class TransactionLoadingFailed extends TransactionState {
  const TransactionLoadingFailed({
    required super.transactions,
    required super.filter,
  });
}

final class AddTransactionSuccess extends TransactionState {
  const AddTransactionSuccess({
    required super.transactions,
    required super.filter,
  });
}

final class AddTransactionFail extends TransactionState {
  const AddTransactionFail({
    required super.transactions,
    required super.filter,
  });
}

final class TransactionsFiltered extends TransactionState {
  const TransactionsFiltered({
    required super.transactions,
    required super.filter,
  });
}
