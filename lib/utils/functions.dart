import 'dart:io';

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

String dateToISO(DateTime d) {
  return "${d.year}-${d.month}-${d.day.toString().padLeft(2, "0")}";
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'الرجاء إدخال اسم مستخدم';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'الرجاء إدخال إيميل';
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) {
    return 'الرجاء إدخال إيميل صالح';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'الرجاء إدخال كلمة مرور';
  }
  if (value.length < 8) {
    return 'يجب أن تحتوي كلمة المرور 8 محارف على الأقل';
  }
  return null;
}

String? validateConfirmPassword(String? confirmPassword, String? password) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'الرجاء تأكيد كلمة المرور';
  }
  if (confirmPassword != password) {
    return "كلمة المرور غير متطابقة";
  }
  return null;
}

String? validateOldPassword(String? value, String? oldPassword) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value != oldPassword) {
    return "كلمة المرور غير متطابقة";
  }
  return null;
}

String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 8) {
    return 'يجب أن تحتوي كلمة المرور 8 محارف على الأقل';
  }
  return null;
}

Future<String> calculateFileHash(File file) async {
  final bytes = await file.readAsBytes();
  return bytes.hashCode.toString();
}
