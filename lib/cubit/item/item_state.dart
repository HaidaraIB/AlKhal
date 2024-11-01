part of 'item_cubit.dart';

@immutable
sealed class ItemState {
  final List<Model>? items;
  final List<Model> categories;
  final String filter;
  final String filterName;

  const ItemState({
    this.items,
    required this.filter,
    required this.categories,
    required this.filterName,
  });
}

final class ItemInitial extends ItemState {
  const ItemInitial({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
  });
}

final class ItemOperationFailed extends ItemState {
  final String err;
  const ItemOperationFailed({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
    required this.err,
  });
}

final class LoadingItems extends ItemState {
  const LoadingItems({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
  });
}

final class LoadingItemsFailed extends ItemOperationFailed {
  const LoadingItemsFailed({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
    required super.err,
  });
}

final class ItemsLoaded extends ItemState {
  const ItemsLoaded({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
  });
}

final class AddItemSuccess extends ItemState {
  const AddItemSuccess({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
  });
}

final class AddItemFail extends ItemOperationFailed {
  const AddItemFail({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
    required super.err,
  });
}

final class UpdateItemSuccess extends ItemState {
  const UpdateItemSuccess({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
  });
}

final class UpdateItemFail extends ItemOperationFailed {
  const UpdateItemFail({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
    required super.err,
  });
}

final class DeleteItemSuccess extends ItemState {
  const DeleteItemSuccess({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
  });
}

final class DeleteItemFail extends ItemOperationFailed {
  const DeleteItemFail({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
    required super.err,
  });
}

final class ItemsFiltered extends ItemState {
  const ItemsFiltered({
    required super.items,
    required super.filter,
    required super.categories,
    required super.filterName,
  });
}
