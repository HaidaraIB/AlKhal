part of 'cash_cubit.dart';

@immutable
sealed class CashState {
  final double cash;
  final double profit;
  final double bills;
  final double reminders;

  const CashState({
    required this.cash,
    required this.profit,
    required this.bills,
    required this.reminders,
  });
}

final class CashInitial extends CashState {
  const CashInitial({
    required super.cash,
    required super.profit,
    required super.bills,
    required super.reminders,
  });
}

final class CashOperationFailed extends CashState {
  final String err;
  const CashOperationFailed({
    required super.cash,
    required super.profit,
    required super.bills,
    required super.reminders,
    required this.err,
  });
}

final class LoadingCash extends CashState {
  const LoadingCash({
    required super.cash,
    required super.profit,
    required super.bills,
    required super.reminders,
  });
}

final class CashRefreshed extends CashState {
  const CashRefreshed({
    required super.cash,
    required super.profit,
    required super.bills,
    required super.reminders,
  });
}

final class CashRefreshingFailed extends CashOperationFailed {
  const CashRefreshingFailed({
    required super.cash,
    required super.profit,
    required super.bills,
    required super.reminders,
    required super.err,
  });
}
