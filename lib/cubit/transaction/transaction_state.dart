part of 'transaction_cubit.dart';

@immutable
sealed class TransactionState {
  const TransactionState();
}

final class TransactionList extends TransactionState {
  final List<Model> transactions;
  final TransactionFilter filter;
  final String dateFilter;
  const TransactionList({
    required this.transactions,
    required this.filter,
    required this.dateFilter,
  });
}

final class TransactionInitial extends TransactionList {
  const TransactionInitial({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionOperationFailed extends TransactionState {
  final String err;
  const TransactionOperationFailed({
    required this.err,
  });
}

final class LoadingTransactions extends TransactionState {
  const LoadingTransactions();
}

final class TransactionsLoaded extends TransactionList {
  const TransactionsLoaded({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionLoadingFailed extends TransactionOperationFailed {
  const TransactionLoadingFailed({
    required super.err,
  });
}

final class AddTransactionSuccess extends TransactionList {
  const AddTransactionSuccess({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class AddTransactionFail extends TransactionOperationFailed {
  const AddTransactionFail({
    required super.err,
  });
}

final class TransactionsFiltered extends TransactionList {
  const TransactionsFiltered({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionCashRefreshed extends TransactionList {
  const TransactionCashRefreshed({
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class TransactionCashRefreshingFailed extends TransactionOperationFailed {
  const TransactionCashRefreshingFailed({
    required super.err,
  });
}

final class UpdateTransactionSuccess extends TransactionList {
  final Transaction updatedTransaction;
  const UpdateTransactionSuccess({
    required this.updatedTransaction,
    required super.transactions,
    required super.filter,
    required super.dateFilter,
  });
}

final class UpdateTransactionsFailed extends TransactionOperationFailed {
  const UpdateTransactionsFailed({
    required super.err,
  });
}
