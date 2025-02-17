import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'date_range_state.dart';

class DateRangeCubit extends Cubit<DateRangeState> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateRangeCubit()
      : super(DateRangeInitial(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ));

  void changeDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    this.startDate = startDate;
    this.endDate = endDate;
    emit(DateRangeChanged(
      startDate: startDate,
      endDate: endDate,
    ));
  }
}
