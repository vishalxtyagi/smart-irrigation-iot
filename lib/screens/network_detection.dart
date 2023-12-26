import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/screens/network_selection.dart';
import 'package:irrigation/utils/size_config.dart';
import 'package:irrigation/utils/styles.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:pulsator/pulsator.dart';

class NetworkDetection extends StatefulWidget {
  const NetworkDetection({super.key});

  @override
  State<NetworkDetection> createState() => _NetworkDetectionState();
}

class _NetworkDetectionState extends State<NetworkDetection> {
  final int _count = 4;
  final int _duration = 3;
  final int _repeatCount = 0;

  late TextEditingController passwordController;
  late TextEditingController deviceIdController;

  StreamSubscription<ProvisioningResponse>? provisionerSubscription;
  final provisioner = Provisioner.espTouch();
  bool showPulsator = false;
  bool deviceDetected = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    deviceIdController = TextEditingController();

    _init();
  }

  void handleProvisioningResponse(response) {
    print('Device connected!');
    final deviceId = response.bssidText.replaceAll(':', '');
    print("Device ID: $deviceId\nconnected to WiFi!");
    setState(() {
      deviceDetected = true;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => NetworkSelection(deviceId: deviceId),
      ),
          (route) => false,
    );
  }

  Future<void> _init() async {
    await _checkPermissions();
    await _checkWiFiConnection();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.location.status;
    if (status.isRestricted || status.isPermanentlyDenied) {
      await Permission.locationWhenInUse.request();
    } else if (status.isDenied) {
      await Permission.location.request();
    }
  }

  Future<void> _checkWiFiConnection() async {
    final info = NetworkInfo();
    final wifiName = await info.getWifiName();
    if (wifiName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect to WiFi'),
        ),
      );
    } else {
      await _showPasswordDialog(wifiName);
    }
  }

  void _stopProvisioning() {
    print(provisionerSubscription);
    provisionerSubscription?.cancel();
    provisioner.stop();
    setState(() {
      showPulsator = false;
    });
  }

  Future<void> _startProvisioning() async {
    Completer<void> provisioningCompleter = Completer();

    try {
      final info = NetworkInfo();

      final wifiName = await info.getWifiName();
      final wifiBSSID = await info.getWifiBSSID();
      print('wifiName: $wifiName');
      print('wifiBSSID: $wifiBSSID');

      // Show the Pulsator only when connected to WiFi
      setState(() {
        showPulsator = true;
      });

      provisionerSubscription = provisioner.listen((response) {
        handleProvisioningResponse(response);
      });

      await Future.any([
        provisioner.start(ProvisioningRequest.fromStrings(
          ssid: wifiName?.replaceAll('"', '') ?? '',
          bssid: wifiBSSID ?? '',
          password: passwordController.text,
        )),
        Future.delayed(const Duration(seconds: 120), () {
          // Timeout if provisioner doesn't complete within 300 seconds
          print('Provisioning timed out');
          _stopProvisioning();
          provisioningCompleter.complete(); // Complete the provisioning process
          _showPasswordDialog(wifiName, errorMessage: 'Password may be incorrect.');
        }),
      ]);
    } catch (e, s) {
      print(e);
      // Handle exceptions
      _stopProvisioning();
    }
  }

  Future<void> _showPasswordDialog(String? wifiName, {String? errorMessage}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter WiFi Password for $wifiName'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(
              hintText: 'Password',
              errorText: errorMessage,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Assign the password and pop the dialog
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // Check if the user submitted a password
    if (passwordController.text.isNotEmpty) {
      // Start provisioning
      _startProvisioning();
    } else {
      // Optionally show a message or handle the case where no password was provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid WiFi password'),
        ),
      );
    }
  }


  Future<void> _showDeviceIdDialog() async {
    String? deviceId;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Device ID'),
          content: TextField(
            controller: deviceIdController,
            decoration: const InputDecoration(
              hintText: 'Device ID',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Assign the device ID and pop the dialog
                deviceId = deviceIdController.text;
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // Check if the user submitted a device ID
    if (deviceId != null && deviceId!.isNotEmpty) {
      // Navigate to a new screen with device info
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NetworkSelection(deviceId: deviceId),
        ),
            (route) => false,
      );
    } else {
      // Optionally show a message or handle the case where no device ID was provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Device ID'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Network detection'), centerTitle: true),
      body: SafeArea(
        bottom: true,
        minimum: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detecting sensor\nnetwork near you..',
              style: Styles.titleStyle,
            ),
            const Gap(10),
            Text(
              'This may take upto 2 minutes',
              style: Styles.textStyle,
            ),
            Expanded(
              child: Stack(
                children: [
                  if (showPulsator)
                  Pulsator(
                    style: const PulseStyle(color: Colors.green),
                    count: _count,
                    duration: Duration(seconds: _duration),
                    repeat: _repeatCount,
                  ),
                  Center(
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/images/${showPulsator ? 'logo_white' : 'logo'}.svg",
                        semanticsLabel: 'Logo',
                        height: 75,
                      ),
                      onPressed: () {
                        showPulsator ? _stopProvisioning() : _init();
                      },
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await _showDeviceIdDialog();
              },
              child: const Text('Connect manually'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    deviceIdController.dispose();
    passwordController.dispose();
    _stopProvisioning();
    super.dispose();
  }
}