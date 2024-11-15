import 'package:alkhal/screens/user_info_screen.dart';
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
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'تأكيد النسخ الاحتياطي',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد إنشاء نسخة احتياطية للبيانات؟ سيتم حذف النسخة الاحتياطية السابقة إن وجدت.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
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
                  bool res = await DatabaseHelper.localBackupDatabase();
                  String msg = "";
                  if (res) {
                    msg = "تم إنشاء نسخة احتياطية بنجاح";
                  } else {
                    msg = "لديك نسخة احتياطية بالفعل.";
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          msg,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('نسخ'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> performRestore() async {
    await requestStoragePermission();
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'تأكيد الاستعادة',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد استعادة البيانات؟ سيتم استبدال البيانات الحالية.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
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
                  bool res = await DatabaseHelper.restoreLocalDatabase();
                  String msg = "";
                  if (res) {
                    msg = "تمت استعادة البيانات بنجاح";
                  } else {
                    msg = "لم يتم العثور على نسخة احتياطية";
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          msg,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('استعادة'),
              ),
            ],
          );
        },
      );
    }
  }

  void performShare() async {
    await DatabaseHelper.shareDatabase();
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: performShare,
                title: const Text(
                  "مشاركة البيانات ",
                  style: TextStyle(fontSize: 20),
                ),
                leading: const Icon(
                  Icons.share,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const UserInfoScreen(),
                )),
                title: const Text(
                  "معلومات الحساب",
                  style: TextStyle(fontSize: 20),
                ),
                leading: const Icon(
                  Icons.account_circle_outlined,
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
