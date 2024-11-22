import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncDbScreen extends StatefulWidget {
  final bool isDbSyncOn;
  final void Function(bool) switchSyncDbValue;
  final Widget Function({
    required String title,
    required Widget trailing,
    Widget? leading,
    void Function()? onTap,
  }) buildOptionTile;

  const SyncDbScreen({
    super.key,
    required this.isDbSyncOn,
    required this.switchSyncDbValue,
    required this.buildOptionTile,
  });

  @override
  State<SyncDbScreen> createState() => _SyncDbScreenState();
}

class _SyncDbScreenState extends State<SyncDbScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        title: const Text("مزامنة البيانات"),
        actions: [
          FutureBuilder<bool?>(
            future: initSyncDbState(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    top: 15,
                    right: 18,
                  ),
                  child: Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: snapshot.data!,
                      onChanged: (value) {
                        setState(() {
                          widget.switchSyncDbValue(value);
                        });
                      },
                    ),
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
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15.0,
          top: 15,
          right: 18,
        ),
        child: ListView(
          children: [
            widget.buildOptionTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                bool? isDbSyncing = prefs.getBool("isDbSyncing");
                if (isDbSyncing == null) {
                  await prefs.setBool("isDbSyncing", false);
                  isDbSyncing = false;
                }
                if (isDbSyncing) {
                  if (context.mounted) {
                    showResultSnackBar(context,
                        "هناك عملية مزامنة جارية الآن يرجى المحاولة لاحقاً");
                  }
                  return;
                }
                await prefs.setBool("isDbSyncing", true);
                if (context.mounted) {
                  showLoadingDialog(context, 'جاري المزامنة...');
                }
                String msg = "";
                try {
                  await DatabaseHelper.remoteBackupDatabase();
                  msg = "تمت مزامنة البيانات بنجاح";
                } catch (e) {
                  msg = "حصل خطأ أثناء مزامنة البيانات يرجى إعادة المحاولة";
                }
                if (context.mounted) {
                  showResultSnackBar(context, msg);
                  Navigator.of(context).pop();
                }
                await prefs.setBool("isDbSyncing", false);
              },
              title: "المزامنة الآن",
              trailing: const Icon(
                Icons.sync,
                size: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}
