import 'dart:convert';

import 'package:alkhal/models/user.dart';
import 'package:alkhal/screens/user_info_screen.dart';
import 'package:alkhal/services/api_calls.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        builder: (BuildContext newContext) {
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
                  Navigator.of(newContext).pop();
                  showLoadingDialog(context, 'جاري الاستعادة...');
                  bool res = await DatabaseHelper.restoreLocalDatabase();
                  String msg = "";
                  if (res) {
                    msg = "تمت استعادة البيانات بنجاح";
                  } else {
                    msg = "لم يتم العثور على نسخة احتياطية";
                  }
                  if (mounted) {
                    showResultSnackBar(context, msg);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('استعادة محلية'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(newContext).pop();
                  showLoadingDialog(context, 'جاري الاستعادة...');
                  var res = await ApiCalls.getRemoteDb(
                      (await User.userInfo())['username']);
                  String msg = "";
                  if (res.statusCode == 200) {
                    await DatabaseHelper.restoreRemoteDatabase(
                      base64Decode(
                        jsonDecode(res.body)['db'],
                      ),
                    );
                    msg = "تمت استعادة البيانات بنجاح";
                  } else if (res.statusCode == 503) {
                    msg = "تحقق من اتصالك بالإنترنت";
                  } else {
                    msg = "لم يتم العثور على نسخة احتياطية";
                  }
                  if (mounted) {
                    showResultSnackBar(context, msg);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('استعادة عبر الانترنت'),
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

  bool? isDbSyncOn = false;

  EdgeInsets optionsPadding = const EdgeInsets.only(bottom: 10);
  TextStyle optionsTextStyle = const TextStyle(fontSize: 22);
  Color backgroundColor = const Color.fromARGB(255, 239, 239, 239);

  Future<bool?> initSyncDbState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDbSyncOn = prefs.getBool("isDbSyncOn");
    if (isDbSyncOn == null) {
      prefs.setBool("isDbSyncOn", false);
      isDbSyncOn = false;
    }
    return isDbSyncOn;
  }

  @override
  void initState() {
    super.initState();
    initSyncDbState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          "الإعدادات",
          style: TextStyle(fontSize: 26),
        ),
      ),
      backgroundColor: backgroundColor,
      body: FutureBuilder<bool?>(
        future: initSyncDbState(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 15, right: 18),
              child: ListView(
                children: [
                  _buildOptionTile(
                    title: "مزامنة البيانات",
                    trailing: const Icon(
                      Icons.sync,
                      size: 30,
                    ),
                    leading: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: isDbSyncOn ?? false,
                        onChanged: (value) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool("isDbSyncOn", value);
                          isDbSyncOn = value;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  _buildOptionTile(
                    onTap: performBackup,
                    title: "النسخ الاحتياطي",
                    trailing: const Icon(
                      Icons.backup,
                      size: 30,
                    ),
                  ),
                  _buildOptionTile(
                    onTap: performRestore,
                    title: "استعادة البيانات ",
                    trailing: const Icon(
                      Icons.restore,
                      size: 30,
                    ),
                  ),
                  _buildOptionTile(
                    onTap: performShare,
                    title: "مشاركة البيانات ",
                    trailing: const Icon(
                      Icons.share,
                      size: 30,
                    ),
                  ),
                  _buildOptionTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UserInfoScreen(),
                    )),
                    title: "معلومات الحساب",
                    trailing: const Icon(
                      Icons.account_circle_outlined,
                      size: 30,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    Widget? leading,
    required Widget trailing,
    void Function()? onTap,
  }) {
    return Padding(
      padding: optionsPadding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: ListTile(
          onTap: onTap,
          title: Text(
            title,
            style: optionsTextStyle,
            textDirection: TextDirection.rtl,
          ),
          trailing: trailing,
          leading: leading,
        ),
      ),
    );
  }
}
