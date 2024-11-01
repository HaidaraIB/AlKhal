import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatDouble(double d) {
  final formatter = intl.NumberFormat('#,##0.##');
  return formatter.format(d);
}

Future<void> requestStoragePermission() async {
  var status = await Permission.manageExternalStorage.status;

  if (!status.isGranted) {
    var result = await Permission.manageExternalStorage.request();

    if (result.isGranted) {
      debugPrint("Storage permission granted.");
    } else if (result.isDenied) {
      debugPrint("Storage permission denied.");
    } else if (result.isPermanentlyDenied) {
      debugPrint(
          "Storage permission permanently denied. Please enable it in settings.");
    }
  } else {
    debugPrint("Storage permission already granted.");
  }
}

Future<void> clearSharedPref() async {
  SharedPreferences instance = await SharedPreferences.getInstance();
  await instance.clear();
}
