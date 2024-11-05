import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_bar_state.dart';

class SearchBarCubit extends Cubit<SearchBarState> {
  SearchBarCubit() : super(SearchBarInitial());

  void changeVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isVisible = prefs.getBool('isSearchBarVisible');
    if (isVisible == null) {
      prefs.setBool("isSearchBarVisible", true);
      isVisible = true;
    } else {
      prefs.setBool("isSearchBarVisible", !isVisible);
      isVisible = !isVisible;
    }
    emit(SearchBarVisibility(isVisible: isVisible));
  }

  void loadVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isVisible = prefs.getBool('isSearchBarVisible');
    if (isVisible == null) {
      prefs.setBool("isSearchBarVisible", true);
      isVisible = true;
    }
    emit(SearchBarVisibility(isVisible: isVisible));
  }
}
