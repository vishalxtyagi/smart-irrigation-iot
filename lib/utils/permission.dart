import 'package:permission_handler/permission_handler.dart';

class AppPermission {

  static Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isRestricted || status.isDenied) {
      await Permission.locationWhenInUse.request();
    } else if (status.isPermanentlyDenied) {
      await Permission.location.request();
    }
  }

}
