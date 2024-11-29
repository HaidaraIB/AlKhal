import 'package:alkhal/services/database_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbSyncer {
  final Connectivity _connectivity = Connectivity();
  Stream<List<ConnectivityResult>>? connectivityStream;
  DbSyncer() {
    connectivityStream = _connectivity.onConnectivityChanged;
    connectivityStream?.listen(
      (List<ConnectivityResult> result) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? isDbSyncOn = prefs.getBool("isDbSyncOn");
        if (isDbSyncOn == null) {
          await prefs.setBool("isDbSyncOn", false);
          isDbSyncOn = false;
        }
        bool? isDbSyncing = prefs.getBool("isDbSyncing");
        if (isDbSyncing == null) {
          await prefs.setBool("isDbSyncing", false);
          isDbSyncing = false;
        }
        if ((result.contains(ConnectivityResult.wifi) ||
                result.contains(ConnectivityResult.mobile)) &&
            isDbSyncOn) {
          await prefs.setBool("isDbSyncing", true);

          try {
            await DatabaseHelper.remoteBackupDatabase();
          } catch (e) {
            debugPrint(e.toString());
          }
          await prefs.setBool("isDbSyncing", false);
        }
      },
    );
  }
}
