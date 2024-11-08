part of 'transaction_cash_cubit.dart';

@immutable
sealed class TransactionCashState {
  final double cash;
  const TransactionCashState({required this.cash});
}

final class TransactionCashInitial extends TransactionCashState {
  const TransactionCashInitial({required super.cash});
}

final class TransactionCashUpdated extends TransactionCashState {
  const TransactionCashUpdated({required super.cash});
}
