part of 'date_range_cubit.dart';

@immutable
sealed class DateRangeState {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeState({
    required this.startDate,
    required this.endDate,
  });
}

final class DateRangeInitial extends DateRangeState {
  const DateRangeInitial({
    required super.startDate,
    required super.endDate,
  });
}

final class DateRangeChanged extends DateRangeState {
  const DateRangeChanged({
    required super.startDate,
    required super.endDate,
  });
}
