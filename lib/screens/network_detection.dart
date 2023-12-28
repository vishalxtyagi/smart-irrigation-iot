import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/screens/network_selection.dart';
import 'package:irrigation/utils/network_connectivity.dart';
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

  final _deviceIdFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController passwordController;
  late TextEditingController deviceIdController;

  final StreamController<ProvisioningResponse> _provisioningController = StreamController<ProvisioningResponse>();
  StreamSubscription<ProvisioningResponse>? provisionerSubscription;

  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  final provisioner = Provisioner.espTouch();
  Map _source = {ConnectivityResult.none: false};
  bool showPulsator = false;
  bool isWifiConnected = false;
  bool deviceDetected = false;

  @override
  void initState() {
    super.initState();
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;

      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.wifi:
          setState(() {
            isWifiConnected = true;
          });
          break;
        default:
          setState(() {
            isWifiConnected = false;
          });
          break;
      }

      if (!isWifiConnected) {
        _stopProvisioning();
      }
    });
    passwordController = TextEditingController();
    deviceIdController = TextEditingController();

    _checkLocationPermissions();
  }

  void handleProvisioningResponse(response) {
    print('Device connected!');
    final deviceId = response.bssidText.replaceAll(':', '');
    print("Device ID: $deviceId\nconnected to WiFi!");
    setState(() {
      deviceDetected = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NetworkSelection(deviceId: deviceId),
      ),
    );
  }

  Future<void> _checkLocationPermissions() async {
    var status = await Permission.location.status;
    if (status.isRestricted || status.isPermanentlyDenied) {
      await Permission.locationWhenInUse.request();
    } else if (status.isDenied) {
      await Permission.location.request();
    }
  }

  void _stopProvisioning() async {
    print(provisioner.running);
    print(provisionerSubscription);
    if (provisionerSubscription != null && !provisionerSubscription!.isPaused) {
      try {
        print('Closing subscription');
        _provisioningController.close();
        print('Canceling subscription');
        await provisionerSubscription!.cancel();
      } catch (e) {
        print('Error while canceling subscription: $e');
      }
    }

    print(provisionerSubscription);
    if (provisioner.running) provisioner.stop();
    setState(() {
      showPulsator = false;
    });
  }

  Future<void> _startProvisioning() async {
    _checkLocationPermissions();

    if (!isWifiConnected) {
      _showWifiConnectionDialog();
      return;
    }

    _stopProvisioning();

    Completer<void> provisioningCompleter = Completer();

    try {
      final info = NetworkInfo();

      final wifiName = await info.getWifiName();
      final wifiBSSID = await info.getWifiBSSID();

      if (passwordController.text.isEmpty) {
        await _showWifiPasswordDialog(wifiName);
      }

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
          _stopProvisioning();
          provisioningCompleter.complete();
          _showWifiPasswordDialog(wifiName, errorMessage: 'Password may be incorrect.');
        }),
      ]);
    } catch (e) {
      print(e);
      _stopProvisioning();
    }
  }

  Future<void> _showWifiPasswordDialog(String? wifiName, {String? errorMessage}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter WiFi Password for $wifiName'),
          content: Form(
            key: _passwordFormKey,
            child: TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                errorText: errorMessage,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter a valid WiFi password';
                }

                if (val.length < 8) {
                  return 'Password must be at least 8 characters long';
                }

                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_passwordFormKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _startProvisioning();
                }
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeviceIdDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Device ID'),
          content: Form(
            key: _deviceIdFormKey,
            child: TextFormField(
              controller: deviceIdController,
              decoration: const InputDecoration(hintText: 'Please enter the device ID'),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter a valid device ID';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_deviceIdFormKey.currentState!.validate()) {
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NetworkSelection(deviceId: deviceIdController.text),
                        ),
                      );
                    }
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWifiConnectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No WiFi connection'),
          content: const Text('You are not connected to a WiFi network. In order to setup your device, please connect to a WiFi network.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Network detection')
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
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
                        showPulsator ? _stopProvisioning() : _startProvisioning();
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
    _networkConnectivity.disposeStream();
    deviceIdController.dispose();
    passwordController.dispose();
    _stopProvisioning();
    super.dispose();
  }
}