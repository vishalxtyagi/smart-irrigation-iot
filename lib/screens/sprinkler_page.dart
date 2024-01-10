import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:irrigation/utils/size_config.dart';
import 'package:irrigation/utils/styles.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:convert';

import 'package:gap/gap.dart';

class SprinklerPage extends StatefulWidget {
  const SprinklerPage({super.key});

  @override
  State<SprinklerPage> createState() => _SprinklerPageState();
}

class _SprinklerPageState extends State<SprinklerPage> {
  String selectedUnit = "Meter";

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
          backgroundColor: Colors.blue[400],
          title: const Text(
            'Smart Irrigation',
            style: TextStyle(
              color: Colors.white
            ),
          ),
          actions: [
          ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Sprinklers in progress',
              style: Styles.titleStyle,
            ),
            const Gap(10),
            Expanded(
              child: Center(
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,// Change to your desired background color
                  ),
                  padding: const EdgeInsets.all(100),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      "assets/images/logo_white.svg",
                      semanticsLabel: 'Logo',
                      height: 100,
                    ),
                    onPressed: () async {
                    },
                  ),
                ),
              ),
            ),
            const Gap(10),
            TextButton(
              onPressed: () async {
              },
              child: Text('Turn on sprinklers'),
            ),
          ],
        )
      ),
    );
  }

}
