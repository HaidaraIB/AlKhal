part of 'add_category_fab_visibility_cubit.dart';

@immutable
sealed class AddCategoryFabVisibilityState {
  final bool isVisible;
  const AddCategoryFabVisibilityState({required this.isVisible});
}

final class AddCategoryFabVisibilityInitial
    extends AddCategoryFabVisibilityState {
  const AddCategoryFabVisibilityInitial({required super.isVisible});
}

final class AddCategoryFabVisible extends AddCategoryFabVisibilityState {
  const AddCategoryFabVisible({required super.isVisible});
}

final class AddCategoryFabInvisible extends AddCategoryFabVisibilityState {
  const AddCategoryFabInvisible({required super.isVisible});
}
