part of 'add_item_fab_visibility_cubit.dart';

@immutable
sealed class AddItemFabVisibilityState {
  final bool isVisible;
  const AddItemFabVisibilityState({required this.isVisible});
}

final class AddItemFabVisibilityInitial extends AddItemFabVisibilityState {
  const AddItemFabVisibilityInitial({required super.isVisible});
}

final class AddItemFabVisible extends AddItemFabVisibilityState {
  const AddItemFabVisible({required super.isVisible});
}

final class AddItemFabInvisible extends AddItemFabVisibilityState {
  const AddItemFabInvisible({required super.isVisible});
}
