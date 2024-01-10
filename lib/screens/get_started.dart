import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/screens/home_page.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/prefs.dart';

import 'network_detection.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {

  @override
  void initState() {
    checkSetup();
    super.initState();
  }

  void checkSetup() {
    AppPrefs().getDevices().then((devices) {
      if (devices.isNotEmpty) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage())
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
        title: const Text(
          'Smart Irrigation',
          style: TextStyle(
            color: AppColors.primaryColor,
          ),
        ),
        backgroundColor: AppColors.accentColor,
        shape: const Border(),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/crop_monitoring.png',
                      width: double.infinity,
                    ),
                    Column(
                      children: [
                        const Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          'Smart Irrigation System',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(20),
                        Text(
                          'Smart Irrigation System is an IoT based system which monitors the soil moisture and sends the data to the cloud. The farmer can access the data from the cloud and can take necessary actions.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),

                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NetworkDetection())
                        );
                      },
                      child: const Text(
                        'Get Started',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
