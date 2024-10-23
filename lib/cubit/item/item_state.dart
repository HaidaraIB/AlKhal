part of 'item_cubit.dart';

@immutable
sealed class ItemState {
  final List<Model>? items;
  const ItemState({this.items});
}

final class ItemInitial extends ItemState {
  const ItemInitial({required super.items});
}

final class LoadingItems extends ItemState {
  const LoadingItems({required super.items});
}

final class LoadingItemsFailed extends ItemState {
  const LoadingItemsFailed({required super.items});
}

final class ItemsLoaded extends ItemState {
  const ItemsLoaded({required super.items});
}

final class AddItemSuccess extends ItemState {
  const AddItemSuccess({required super.items});
}

final class AddItemFail extends ItemState {
  const AddItemFail({required super.items});
}

final class UpdateItemSuccess extends ItemState {
  const UpdateItemSuccess({required super.items});
}

final class UpdateItemFail extends ItemState {
  const UpdateItemFail({required super.items});
}

final class DeleteItemSuccess extends ItemState {
  const DeleteItemSuccess({required super.items});
}

final class DeleteItemFail extends ItemState {
  const DeleteItemFail({required super.items});
}
