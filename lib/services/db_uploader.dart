import 'package:alkhal/services/database_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbUploader {
  final Connectivity _connectivity = Connectivity();
  Stream<List<ConnectivityResult>>? connectivityStream;
  DbUploader() {
    connectivityStream = _connectivity.onConnectivityChanged;
    connectivityStream?.listen(
      (List<ConnectivityResult> result) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? isDbSyncOn = prefs.getBool("isDbSyncOn");
        if (isDbSyncOn == null) {
          await prefs.setBool("isDbSyncOn", false);
          isDbSyncOn = false;
        }
        if (!result.contains(ConnectivityResult.none) && isDbSyncOn) {
          await DatabaseHelper.remoteBackupDatabase();
        }
      },
    );
  }
}
