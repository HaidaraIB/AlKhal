import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> performBackup() async {
    await requestStoragePermission();
    await DatabaseHelper.backupDatabase(DatabaseHelper.dbName);
  }

  Future<void> performRestore() async {
    await requestStoragePermission();
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('تأكيد الاستعادة'),
            content: const Text(
              'هل أنت متأكد أنك تريد استعادة البيانات؟ سيتم استبدال البيانات الحالية.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await DatabaseHelper.restoreDatabase(DatabaseHelper.dbName);
                },
                child: const Text('استعادة'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: performBackup,
                title: const Text(
                  "النسخ الاحتياطي",
                  style: TextStyle(fontSize: 20),
                ),
                leading: const Icon(
                  Icons.backup,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: performRestore,
                title: const Text(
                  "استعادة البيانات ",
                  style: TextStyle(fontSize: 20),
                ),
                leading: const Icon(
                  Icons.restore,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
