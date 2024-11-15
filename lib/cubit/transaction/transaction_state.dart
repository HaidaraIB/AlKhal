part of 'transaction_cubit.dart';

@immutable
sealed class TransactionState {
  final List<Model> transactions;
  final TransactionFilter filter;
  final String dateFilter;
  const TransactionState({
    required this.transactions,
    required this.filter,
    required this.dateFilter,
  });
}

final class TransactionInitial extends TransactionState {
  const TransactionInitial({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionOperationFailed extends TransactionState {
  final String err;
  const TransactionOperationFailed({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
    required this.err,
  });
}

final class LoadingTransactions extends TransactionState {
  const LoadingTransactions({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionsLoaded extends TransactionState {
  const TransactionsLoaded({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionLoadingFailed extends TransactionOperationFailed {
  const TransactionLoadingFailed({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
    required super.err,
  });
}

final class AddTransactionSuccess extends TransactionState {
  const AddTransactionSuccess({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class AddTransactionFail extends TransactionOperationFailed {
  const AddTransactionFail({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
    required super.err,
  });
}

final class TransactionsFiltered extends TransactionState {
  const TransactionsFiltered({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionCashRefreshed extends TransactionState {
  const TransactionCashRefreshed({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionCashRefreshingFailed extends TransactionOperationFailed {
  const TransactionCashRefreshingFailed({
    required super.dateFilter,
    required super.err,
    required super.filter,
    required super.transactions,
  });
}

final class UpdateTransactionSuccess extends TransactionState {
  const UpdateTransactionSuccess({
    required super.transactions,
    required super.dateFilter,
    required super.filter,
  });
}

final class UpdateTransactionsFailed extends TransactionOperationFailed {
  const UpdateTransactionsFailed({
    required super.dateFilter,
    required super.err,
    required super.filter,
    required super.transactions,
  });
}
