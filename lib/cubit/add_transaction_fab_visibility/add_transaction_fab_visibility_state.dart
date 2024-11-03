part of 'add_transaction_fab_visibility_cubit.dart';

@immutable
sealed class AddTransactionFabVisibilityState {
  final bool isVisible;
  const AddTransactionFabVisibilityState({required this.isVisible});
}

final class AddTransactionFabVisibilityInitial
    extends AddTransactionFabVisibilityState {
  const AddTransactionFabVisibilityInitial({required super.isVisible});
}

final class AddTransactionFabVisible extends AddTransactionFabVisibilityState {
  const AddTransactionFabVisible({required super.isVisible});
}

final class AddTransactionFabInvisible
    extends AddTransactionFabVisibilityState {
  const AddTransactionFabInvisible({required super.isVisible});
}
