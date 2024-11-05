part of 'search_bar_cubit.dart';

@immutable
sealed class SearchBarState {
  const SearchBarState();
}

final class SearchBarInitial extends SearchBarState {}

final class SearchBarVisibility extends SearchBarState {
  final bool isVisible;
  const SearchBarVisibility({required this.isVisible});
}
