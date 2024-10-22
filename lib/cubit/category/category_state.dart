part of 'category_cubit.dart';

@immutable
sealed class CategoryState {
  final List<Model> categories;
  const CategoryState({required this.categories});
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial({required super.categories});
}

final class LoadingCategories extends CategoryState {
  const LoadingCategories({required super.categories});
}

final class CategoriesLoaded extends CategoryState {
  const CategoriesLoaded({required super.categories});
}
