import 'package:intl/intl.dart' as intl;
// import 'package:permission_handler/permission_handler.dart';

String formatDouble(double d) {
  final formatter = intl.NumberFormat('#,##0.##');
  return formatter.format(d);
}

intl.DateFormat arDateTimeFormat =
    intl.DateFormat('EEEE d MMMM y, h:mm a', 'ar_SA');

// Future<void> requestStoragePermission() async {
//   var status = await Permission.storage.status;
//   if (!status.isGranted) {
//     status = await Permission.storage.request();
//   }
// }
