part of 'add_spending_fab_visibility_cubit.dart';

@immutable
sealed class AddSpendingFabVisibilityState {
  final bool isVisible;

  const AddSpendingFabVisibilityState({
    required this.isVisible,
  });
}

final class AddSpendingFabVisibilityInitial
    extends AddSpendingFabVisibilityState {
  const AddSpendingFabVisibilityInitial({
    required super.isVisible,
  });
}

final class AddSpendingFabVisible extends AddSpendingFabVisibilityState {
  const AddSpendingFabVisible({
    required super.isVisible,
  });
}

final class AddSpendingFabInvisible extends AddSpendingFabVisibilityState {
  const AddSpendingFabInvisible({
    required super.isVisible,
  });
}
