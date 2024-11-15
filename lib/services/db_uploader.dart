import 'package:alkhal/services/database_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DbUploader {
  final Connectivity _connectivity = Connectivity();
  Stream<List<ConnectivityResult>>? connectivityStream;
  DbUploader() {
    connectivityStream = _connectivity.onConnectivityChanged;
    connectivityStream?.listen(
      (List<ConnectivityResult> result) async {
        if (!result.contains(ConnectivityResult.none)) {
          await DatabaseHelper.remoteBackupDatabase();
        }
      },
    );
  }
}
