import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const String _keyDevices = 'iotDevices';
  static const String _keyNotifications = 'enableNotifications';
  static const String _keySelectedUnit = 'selectedUnit';

  static final AppPrefs _instance = AppPrefs._internal();

  factory AppPrefs() {
    return _instance;
  }

  AppPrefs._internal();

  Future<void> saveDevices(List<Map<String, dynamic>> devices) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyDevices,
      devices.map((e) => json.encode(e)).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> devices = prefs.getStringList(_keyDevices) ?? [];
    return devices.map((e) => Map<String, dynamic>.from(json.decode(e))).toList();
  }

  Future<Map<String, dynamic>> getDevice(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> devices = prefs.getStringList(_keyDevices) ?? [];
    return devices.map((e) => Map<String, dynamic>.from(json.decode(e))).firstWhere((element) => element['id'] == id);
  }

  Future<int> getDeviceCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> devices = prefs.getStringList(_keyDevices) ?? [];
    return devices.length;
  }

  Future<void> clearDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDevices);
  }

  Future<void> deleteDevice(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> devices = prefs.getStringList(_keyDevices) ?? [];
    devices.removeWhere((element) => json.decode(element)['id'] == id);
    await prefs.setStringList(_keyDevices, devices);
  }

  Future<void> addDevice(Map<String, dynamic> device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> devices = prefs.getStringList(_keyDevices) ?? [];
    devices.add(json.encode(device));
    await prefs.setStringList(_keyDevices, devices);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }

  Future<bool> areNotificationsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? false;
  }

  Future<void> saveSelectedUnit(String unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedUnit, unit);
  }

  Future<String?> getSelectedUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedUnit);
  }

  Future<void> clearSelectedUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedUnit);
  }
}
