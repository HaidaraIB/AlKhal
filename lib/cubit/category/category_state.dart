part of 'category_cubit.dart';

@immutable
sealed class CategoryState {
  final List<Model> categories;
  const CategoryState({required this.categories});
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial({required super.categories});
}

final class CategoryOperationFailed extends CategoryState {
  final String err;
  const CategoryOperationFailed({
    required super.categories,
    required this.err,
  });
}

final class LoadingCategories extends CategoryState {
  const LoadingCategories({required super.categories});
}

final class CategoriesLoaded extends CategoryState {
  const CategoriesLoaded({required super.categories});
}

final class LoadingCategoriesFailed extends CategoryOperationFailed {
  const LoadingCategoriesFailed({
    required super.categories,
    required super.err,
  });
}

final class DeleteCategorySuccess extends CategoryState {
  const DeleteCategorySuccess({required super.categories});
}

final class DeleteCategoryFail extends CategoryOperationFailed {
  const DeleteCategoryFail({
    required super.categories,
    required super.err,
  });
}

final class AddCategorySuccess extends CategoryState {
  const AddCategorySuccess({required super.categories});
}

final class AddCategoryFail extends CategoryOperationFailed {
  const AddCategoryFail({
    required super.categories,
    required super.err,
  });
}

final class UpdateCategorySuccess extends CategoryState {
  const UpdateCategorySuccess({required super.categories});
}

final class UpdateCategoryFail extends CategoryOperationFailed {
  const UpdateCategoryFail({
    required super.categories,
    required super.err,
  });
}
