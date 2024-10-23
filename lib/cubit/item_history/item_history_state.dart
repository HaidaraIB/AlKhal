part of 'item_history_cubit.dart';

@immutable
sealed class ItemHistoryState {
  final List<Model> itemHistory;
  const ItemHistoryState({required this.itemHistory});
}

final class ItemHistoryInitial extends ItemHistoryState {
  const ItemHistoryInitial({required super.itemHistory});
}

final class AddItemHistorySuccess extends ItemHistoryState {
  const AddItemHistorySuccess({required super.itemHistory});
}

final class AddItemHistoryFail extends ItemHistoryState {
  const AddItemHistoryFail({required super.itemHistory});
}

final class LoadingHistory extends ItemHistoryState {
  const LoadingHistory({required super.itemHistory});
}

final class LoadingHistoryFailed extends ItemHistoryState {
  const LoadingHistoryFailed({required super.itemHistory});
}

final class HistoryLoaded extends ItemHistoryState {
  const HistoryLoaded({required super.itemHistory});
}
