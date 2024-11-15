part of 'cash_cubit.dart';

@immutable
sealed class CashState {
  const CashState();
}

final class CashInitial extends CashState {
  final double cash;
  final double profit;
  final double bills;
  final double remainders;
  const CashInitial({
    required this.cash,
    required this.profit,
    required this.bills,
    required this.remainders,
  });
}

final class CashOperationFailed extends CashState {
  final String err;
  const CashOperationFailed({
    required this.err,
  });
}

final class LoadingCash extends CashState {}

final class CashRefreshed extends CashState {
  final double cash;
  final double profit;
  final double bills;
  final double remainders;
  const CashRefreshed({
    required this.cash,
    required this.profit,
    required this.bills,
    required this.remainders,
  });
}

final class CashRefreshingFailed extends CashOperationFailed {
  const CashRefreshingFailed({
    required super.err,
  });
}

final class SettingsScreenPopped extends CashState {}
