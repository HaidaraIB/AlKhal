import 'package:intl/intl.dart';

String formatDouble(double d) {
  final formatter = NumberFormat('#,##0.##');
  return formatter.format(d);
}
