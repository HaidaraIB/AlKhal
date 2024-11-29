part of 'spending_cubit.dart';

@immutable
sealed class SpendingState {
  const SpendingState();
}

final class SpendingInitial extends SpendingState {}

final class SpendingOperationFailed extends SpendingState {
  final String err;
  const SpendingOperationFailed({
    required this.err,
  });
}

final class SpendingsList extends SpendingState {
  final List<Model?> spendings;
  const SpendingsList({
    required this.spendings,
  });
}

final class AddSpendingSuccess extends SpendingsList {
  const AddSpendingSuccess({
    required super.spendings,
  });
}

final class LoadingSpendings extends SpendingState {}

final class LoadingSpendingsFailed extends SpendingOperationFailed {
  const LoadingSpendingsFailed({
    required super.err,
  });
}

final class SpendingsLoaded extends SpendingsList {
  const SpendingsLoaded({
    required super.spendings,
  });
}

final class AddSpendingFail extends SpendingOperationFailed {
  const AddSpendingFail({
    required super.err,
  });
}
