import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_scan_animation/device_scan_animation.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/screens/network_selection.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/permission.dart';
import 'package:irrigation/utils/size_config.dart';
import 'package:irrigation/utils/styles.dart';
import 'package:pulsator/pulsator.dart';


class NetworkDetection extends StatefulWidget {
  const NetworkDetection({
    this.isAddDevice = false,
    super.key
  });

  final bool isAddDevice;

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

  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final List<String> _devices = [];

  Stream<ESPTouchResult>? _espStream;
  StreamSubscription<ESPTouchResult>? _espSubscription;

  int deviceCount = 5;
  bool isWifiConnected = true;
  bool showPulsator = false;
  bool isBroad = true;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((e) {
      setState(() {
        isWifiConnected = e == ConnectivityResult.wifi;
      });
    });
    passwordController = TextEditingController();
    deviceIdController = TextEditingController();

    _initializeProvisioning();
  }

  Future<void> _initializeProvisioning() async {
    if (isWifiConnected) {
      Map<String, String>? wifiData = await EsptouchSmartconfig.wifiData();
      if (wifiData != null) {
        await _startProvisioning(wifiData);
      }
    }
  }

  Future<void> _stopProvisioning() async {
    _devices.clear();
    await _espSubscription?.cancel();
    setState(() {
      showPulsator = false;
    });
  }

  Future<void> _startProvisioning(Map<String, String> map) async {
    await AppPermission.requestLocationPermission();
    await _showWifiPasswordDialog(map['wifiName']);
    await _stopProvisioning();
    _espStream = EsptouchSmartconfig.run(
        ssid: map['wifiName']!,
        bssid: map['bssid']!,
        password: passwordController.text,
        deviceCount: deviceCount.toString(),
        isBroad: isBroad);

    setState(() {
      showPulsator = true;
    });

    _espSubscription = _espStream!.listen((event) {
      setState(() {
        _devices.add(event.bssid.replaceAll(':', '').toUpperCase());
      });
    });
  }

  Future<void> _showWifiPasswordDialog(String? wifiName, {String? errorMessage}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Enter WiFi Password for $wifiName'),
            content: Form(
                key: _passwordFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(hintText: 'Please enter the WiFi password'),
                    ),
                    const Gap(30),
                    Text('Total Devices to be connected: $deviceCount'),
                    // slider
                    Slider(
                      value: deviceCount.toDouble(),
                      label: deviceCount.toString(),
                      onChanged: (value) {
                        setState(() {
                          deviceCount = value.toInt();
                        });
                      },
                      min: 1,
                      max: 5,
                      divisions: 4,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isBroad,
                          onChanged: (val) {
                            setState(() {
                              isBroad = val!;
                            });
                          },
                        ),
                        const Text('Broadcast to all devices'),
                      ],
                    ),
                    if (errorMessage != null) Text(errorMessage, style: const TextStyle(color: Colors.red)),
                  ],
                )
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (_passwordFormKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Proceed'),
              ),
            ],
          );
        });
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
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NetworkSelection(
                        devices: [deviceIdController.text.toUpperCase()],
                        isAddDevice: widget.isAddDevice,
                      ),
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
        child: isWifiConnected ? Column(
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
              child: FutureBuilder<Map<String, String>?>(
                future: EsptouchSmartconfig.wifiData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                        children: [
                          if (showPulsator) _devices.isEmpty ?
                            Pulsator(
                              style: const PulseStyle(color: Colors.green),
                              count: _count,
                              duration: Duration(seconds: _duration),
                              repeat: _repeatCount,
                            ) : Center(
                            child: DeviceScanWidget(
                              duration: Duration(seconds: _duration),
                              newNodesDuration: const Duration(seconds: 10),
                              scanColor: Colors.lightGreenAccent,
                              centerNodeColor: AppColors.primaryColor,
                              nodeColor: Colors.green,
                              layers: _devices.length,
                              gap: _devices.length == 1 ? 100 : getProportionateScreenWidth(165) / _devices.length
                            ),
                          ),
                          Center(
                            child: IconButton(
                              icon: SvgPicture.asset(
                                "assets/images/${(showPulsator && _devices.isEmpty) ? 'logo_white' : 'logo'}.svg",
                                semanticsLabel: 'Logo',
                                height: 75,
                              ),
                              onPressed: () async {
                                showPulsator ? await _stopProvisioning() : await _startProvisioning(snapshot.data!);
                              },
                            ),
                          ),
                        ],
                      );
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  }
                }),
            ),
            TextButton(
              onPressed: () async {
                print(widget.isAddDevice);
                _devices.isNotEmpty ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NetworkSelection(
                      devices: _devices,
                      isAddDevice: widget.isAddDevice,
                    ),
                  ),
                ) :
                await _showDeviceIdDialog();
              },
              child: Text(_devices.isEmpty ? 'Connect manually' : 'Proceed'),
            ),
          ],
        ) : Column(
          children: [
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 200,
                    color: Colors.red,
                  ),
                  const Gap(30),
                  RichText(
                    text: const TextSpan(
                      text: 'If you want to set up a device ',
                      style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      children: [
                        TextSpan(
                          text: '(i.e., add/change WiFi configurations of sensor device)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ', then please connect to the same WiFi network.\n\n\n',
                        ),
                      ]
                    )
                  ),
                  RichText(
                      text: const TextSpan(
                          style: TextStyle(color: TextColors.dark, fontSize: 15),
                          children: [
                            TextSpan(
                              text: 'Note: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'If the device is already set up, ',
                            ),
                            TextSpan(
                              text: 'you can use the connect manually option by entering the device ID.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ]
                      )
                  ),
                ]
              ),
            ),
            TextButton(
              onPressed: () async {
                await AppSettings.openAppSettings(type: AppSettingsType.wifi);
              },
              child: const Text('Open WiFi settings'),
            ),
            const Gap(20),
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
  void dispose() async {
    await _stopProvisioning();
    await _connectivitySubscription.cancel();
    deviceIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}