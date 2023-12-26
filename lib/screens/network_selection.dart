import 'package:flutter/material.dart';
import 'package:pulsator/pulsator.dart';

class NetworkSelection extends StatefulWidget {
  var deviceId;

  NetworkSelection({super.key, required this.deviceId});

  @override
  State<NetworkSelection> createState() => _NetworkSelectionState();
}

class _NetworkSelectionState extends State<NetworkSelection> {
  final int _count = 4;
  final int _duration = 3;
  final int _repeatCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network selection..')),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Pulsator(
                    style: const PulseStyle(color: Colors.red),
                    count: _count,
                    duration: Duration(seconds: _duration),
                    repeat: _repeatCount,
                  ),
                  Center(
                    child: Image.asset(
                      'assets/android_phone.png',
                      width: 128,
                      height: 128,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}