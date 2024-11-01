import 'package:intl/intl.dart' as intl;
import 'package:permission_handler/permission_handler.dart';

String formatDouble(double d) {
  final formatter = intl.NumberFormat('#,##0.##');
  return formatter.format(d);
}

intl.DateFormat arDateTimeFormat =
    intl.DateFormat('EEEE d MMMM y, h:mm a', 'ar_SA');

Future<void> requestStoragePermission() async {
  var status = await Permission.manageExternalStorage.status;

  if (!status.isGranted) {
    var result = await Permission.manageExternalStorage.request();

    if (result.isGranted) {
      print("Storage permission granted.");
    } else if (result.isDenied) {
      print("Storage permission denied.");
    } else if (result.isPermanentlyDenied) {
      print(
          "Storage permission permanently denied. Please enable it in settings.");
    }
  } else {
    print("Storage permission already granted.");
  }
}
