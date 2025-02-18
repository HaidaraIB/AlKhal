import 'package:alkhal/services/db_syncer.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await DbSyncer().syncData();
    return Future.value(true);
  });
}
