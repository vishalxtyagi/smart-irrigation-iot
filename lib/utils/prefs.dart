import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const String _keyDevices = 'iotDevices';
  static const String _keyNotifications = 'enableNotifications';

  static final AppSettings _instance = AppSettings._internal();

  factory AppSettings() {
    return _instance;
  }

  AppSettings._internal();

  Future<void> saveDevices(List<String> devices) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyDevices, devices);
  }

  Future<List<String>> getDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyDevices) ?? [];
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }

  Future<bool> areNotificationsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? false;
  }
}
