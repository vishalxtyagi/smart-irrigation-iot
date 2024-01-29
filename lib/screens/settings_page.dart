import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:irrigation/screens/network_detection.dart';
import 'package:irrigation/screens/network_selection.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/prefs.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              // User
              SimpleUserCard(
                userName: "Smart Irrigation",
                userProfilePic: const AssetImage('assets/images/crop_monitoring.png'),
              ),
             SettingsGroup(
                items: [
                  SettingsItem(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NetworkDetection(isAddDevice: true)),
                      );
                    },
                    icons: CupertinoIcons.add,
                    iconStyle: IconStyle(),
                    title: 'Add a device',
                    subtitle: "Add a new device to your account",
                  ),
                  SettingsItem(
                    onTap: () async {
                      List<String> devices = [];
                      await AppPrefs().getDevices().then((units) {
                        if (units.isNotEmpty) {
                          for (var element in units) {
                            devices.add(element['id']);
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NetworkSelection(devices: devices, isManageDevices: true)),
                          );
                        }
                      });
                    },
                    icons: Icons.devices,
                    title: 'Manage devices',
                    subtitle: "Manage your devices",
                  ),
                ],
              ),
              SettingsGroup(
                items: [
                  SettingsItem(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LicensePage())
                      );
                    },
                    icons: Icons.info_outline_rounded,
                    iconStyle: IconStyle(
                      backgroundColor: Colors.purple,
                    ),
                    title: 'Open source licenses',
                    subtitle: "Learn more about the licenses used in this app",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}