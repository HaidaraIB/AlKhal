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

final class LoadingCategoriesFailed extends CategoryState {
  const LoadingCategoriesFailed({required super.categories});
}

final class DeleteCategorySuccess extends CategoryState {
  const DeleteCategorySuccess({required super.categories});
}

final class DeleteCategoryFail extends CategoryState {
  const DeleteCategoryFail({required super.categories});
}

final class AddCategorySuccess extends CategoryState {
  const AddCategorySuccess({required super.categories});
}

final class AddCategoryFail extends CategoryState {
  const AddCategoryFail({required super.categories});
}

final class UpdateCategorySuccess extends CategoryState {
  const UpdateCategorySuccess({required super.categories});
}

final class UpdateCategoryFail extends CategoryState {
  const UpdateCategoryFail({required super.categories});
}
