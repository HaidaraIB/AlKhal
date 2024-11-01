part of 'cash_cubit.dart';

@immutable
sealed class CashState {
  final double cash;
  final double profit;
  final double bills;

  const CashState({
    required this.cash,
    required this.profit,
    required this.bills,
  });
}

final class CashInitial extends CashState {
  const CashInitial({
    required super.cash,
    required super.profit,
    required super.bills,
  });
}

final class CashOperationFailed extends CashState {
  final String err;
  const CashOperationFailed({
    required super.cash,
    required super.profit,
    required super.bills,
    required this.err,
  });
}

final class LoadingCash extends CashState {
  const LoadingCash({
    required super.cash,
    required super.profit,
    required super.bills,
  });
}

final class CashRefreshed extends CashState {
  const CashRefreshed({
    required super.cash,
    required super.profit,
    required super.bills,
  });
}

final class CashRefreshingFailed extends CashOperationFailed {
  const CashRefreshingFailed({
    required super.cash,
    required super.profit,
    required super.bills,
    required super.err,
  });
}
