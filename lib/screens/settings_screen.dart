import 'package:alkhal/models/user.dart';
import 'package:alkhal/screens/sync_db_screen.dart';
import 'package:alkhal/screens/user_info_screen.dart';
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
                  String msg = "";
                  final prefs = await SharedPreferences.getInstance();
                  int? lastPendingOperationId =
                      prefs.getInt("last_pending_operation_id") ?? 0;
                  int statusCode = await DatabaseHelper.getPendingOperations(
                    (await User.userInfo())['username'],
                    lastPendingOperationId,
                  );
                  if (statusCode == 200) {
                    msg = "تمت استعادة البيانات بنجاح";
                  } else if (statusCode == -200) {
                    msg = "البيانات محدثة بالفعل";
                  } else if (statusCode == 503) {
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

  TextStyle optionsTextStyle = const TextStyle(fontSize: 22);

  void switchSyncDbValue(bool value) async {
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isDbSyncOn", value);
    }
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
        backgroundColor: Colors.white,
        title: const Text("الإعدادات"),
      ),
      backgroundColor: Colors.white,
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (newContext) {
                          return PopScope(
                            onPopInvokedWithResult: (didPop, result) =>
                                setState(() {}),
                            child: SyncDbScreen(
                              isDbSyncOn: snapshot.data!,
                              switchSyncDbValue: switchSyncDbValue,
                              buildOptionTile: _buildOptionTile,
                            ),
                          );
                        },
                      ),
                    ),
                    trailing: const Icon(
                      Icons.sync,
                      size: 30,
                    ),
                    leading: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: snapshot.data ?? false,
                        onChanged: (value) {
                          setState(() {
                            switchSyncDbValue(value);
                          });
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
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
