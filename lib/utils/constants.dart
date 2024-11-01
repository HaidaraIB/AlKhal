import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

intl.DateFormat arDateTimeFormat =
    intl.DateFormat('EEEE d MMMM y, h:mm a', 'ar_SA');

String dateFormat = "yyyy-MM-dd";

Widget buildErrorWidget(String err) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Something went wrong!",
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
      Text(
        err,
        style: const TextStyle(fontSize: 20, color: Colors.red),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
