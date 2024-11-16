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
        if ((result.contains(ConnectivityResult.wifi) ||
                result.contains(ConnectivityResult.mobile)) &&
            isDbSyncOn) {
          // var userInfo = await User.userInfo();
          // var res = await ApiCalls.getRemoteDb(userInfo['username']);
          // if (res.statusCode == 200) {
          //   await DatabaseHelper.restoreRemoteDatabase(
          //     base64Decode(
          //       jsonDecode(res.body)['db'],
          //     ),
          //   );
          // }
          try {
            await DatabaseHelper.remoteBackupDatabase();
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      },
    );
  }
}
