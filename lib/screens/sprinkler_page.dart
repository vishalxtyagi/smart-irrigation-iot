import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:irrigation/utils/shared.dart';
import 'package:irrigation/utils/size_config.dart';
import 'package:irrigation/utils/styles.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:gap/gap.dart';

class SprinklerPage extends StatefulWidget {
  final Function(bool) updateBottomNavBarColor;

  const SprinklerPage({super.key, required this.updateBottomNavBarColor});

  @override
  State<SprinklerPage> createState() => _SprinklerPageState();
}

class _SprinklerPageState extends State<SprinklerPage> {
  late DatabaseReference _databaseReference;
  bool sprinklerState = false;
  bool isBlocked = false;
  String? selectedUnit;
  bool isCardView = false;
  List<String> units = [];

  double rainfall = 0.0;
  double prediction = 0.0;

  @override
  void initState() {
    super.initState();
    initFirebase();
    loadAllUnits();
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp();
    _databaseReference = FirebaseDatabase.instance.ref("FirebaseIOT");
    // Set up a listener for changes in the sprinkler state
  }

  Future<void> listenDb(String unit) async {
    print('Sprinkler state: $unit');
    _databaseReference.child(unit).child('sprinklers').onValue.listen((event) {
      final data = event.snapshot.value;
      print('Sprinkler state: $data');
      setState(() {
        sprinklerState = (data == 'ON');
        isBlocked = (data == 'BLOCKED');
        widget.updateBottomNavBarColor(sprinklerState);
      });
    });
  }

  Future<void> loadAllUnits() async {
    String? savedUnit = await AppPrefs().getSelectedUnit();
    final devices = await AppPrefs().getDevices();
    setState(() {
      units = List.generate(devices.length, (index) => devices[index]['id']);
      selectedUnit = savedUnit ?? units[0];
      listenDb(selectedUnit!);
    });
  }

  Future<List<DropdownMenuItem<String>>> _buildDropdownItems() async {
    // show units as Unit 1, Unit 2, etc.
    return List.generate(units.length, (index) {
      return DropdownMenuItem<String>(
        value: units[index],
        child: Text('Unit ${index + 1}'),
      );
    });
  }

  void toggleSprinklerState(String unit) {
    // Toggle the sprinkler state in the database
    _databaseReference.child(unit).child('sprinklers').set(sprinklerState ? 'OFF' : 'ON');
  }

  @override
  Widget build(BuildContext context) {
    final sharedValue = Provider.of<SharedValue>(context);

    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: sprinklerState ? Colors.blue[400] : Colors.white,
      appBar: AppBar(
          backgroundColor: sprinklerState ? Colors.blue[400] : Colors.white,
          title: Text(
            'Smart Irrigation',
            style: TextStyle(
              color: sprinklerState ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            FutureBuilder(future: _buildDropdownItems(), builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                print(snapshot.data);
                return DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: selectedUnit,
                    items: snapshot.data,
                    onChanged: (value) {
                      setState(() {
                        selectedUnit = value!;
                        AppPrefs().saveSelectedUnit(value);
                        
                        listenDb(selectedUnit!);
                      });
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Gap(20),
            RichText(
              text: TextSpan(
                text: 'Motor: ',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: sprinklerState ? Colors.white : Colors.black,
                ),
                children: [
                  TextSpan(
                    text: sprinklerState ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sprinklerState ? Colors.white : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: sprinklerState ? Container(
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
                ) : _buildGauge(
                    sharedValue.rain,
                    sharedValue.prediction
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (isBlocked) {
                  return;
                }

                toggleSprinklerState(selectedUnit!);
              },
              style: Theme.of(context).textButtonTheme.style!.copyWith(
                backgroundColor: MaterialStateProperty.all<Color>(
                  sprinklerState ? Colors.white : AppColors.primaryColor,
                ),
              ),
              child: Text(sprinklerState ? 'Turn off motor' : 'Turn on motor',
                style: TextStyle(
                  color: sprinklerState ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget _buildGauge(rainfall, prediction) {
    final result = calculateIrrigationValue(
        rainfall,
        prediction
    );

    return Column(
      children: [
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
                showAxisLine: false,
                showLabels: false,
                showTicks: false,
                startAngle: 180,
                endAngle: 360,
                maximum: 120,
                canScaleToFit: true,
                radiusFactor: 0.79,
                pointers: <GaugePointer>[
                  NeedlePointer(
                      needleEndWidth: 5,
                      needleLength: 0.7,
                      value: result,
                      knobStyle: KnobStyle(knobRadius: 0)),
                ],
                ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: 0,
                      endValue: 20,
                      startWidth: 0.45,
                      endWidth: 0.45,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: const Color(0xFFDD3800)),
                  GaugeRange(
                      startValue: 20.5,
                      endValue: 40,
                      startWidth: 0.45,
                      sizeUnit: GaugeSizeUnit.factor,
                      endWidth: 0.45,
                      color: const Color(0xFFFF4100)),
                  GaugeRange(
                      startValue: 40.5,
                      endValue: 60,
                      startWidth: 0.45,
                      sizeUnit: GaugeSizeUnit.factor,
                      endWidth: 0.45,
                      color: const Color(0xFFFFBA00)),
                  GaugeRange(
                      startValue: 60.5,
                      endValue: 80,
                      startWidth: 0.45,
                      sizeUnit: GaugeSizeUnit.factor,
                      endWidth: 0.45,
                      color: const Color(0xFFFFDF10)),
                  GaugeRange(
                      startValue: 80.5,
                      endValue: 100,
                      sizeUnit: GaugeSizeUnit.factor,
                      startWidth: 0.45,
                      endWidth: 0.45,
                      color: const Color(0xFF8BE724)),
                  GaugeRange(
                      startValue: 100.5,
                      endValue: 120,
                      startWidth: 0.45,
                      endWidth: 0.45,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: const Color(0xFF64BE00)),
                ]),
            RadialAxis(
              showAxisLine: false,
              showLabels: false,
              showTicks: false,
              startAngle: 180,
              endAngle: 360,
              maximum: 120,
              radiusFactor: 0.85,
              canScaleToFit: true,
              pointers: <GaugePointer>[
                MarkerPointer(
                    markerType: MarkerType.text,
                    text: 'Poor',
                    value: 20.5,
                    textStyle: GaugeTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCardView ? 14 : 18,
                        fontFamily: 'Times'),
                    offsetUnit: GaugeSizeUnit.factor,
                    markerOffset: -0.12),
                MarkerPointer(
                    markerType: MarkerType.text,
                    text: 'Average',
                    value: 60.5,
                    textStyle: GaugeTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCardView ? 14 : 18,
                        fontFamily: 'Times'),
                    offsetUnit: GaugeSizeUnit.factor,
                    markerOffset: -0.12),
                MarkerPointer(
                    markerType: MarkerType.text,
                    text: 'Good',
                    value: 100.5,
                    textStyle: GaugeTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCardView ? 14 : 18,
                        fontFamily: 'Times'),
                    offsetUnit: GaugeSizeUnit.factor,
                    markerOffset: -0.12)
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Based on rainfall: $rainfall (mm)\nAI Model prediction: $prediction\n\nYour field is in the ${result > 60 ? 'good' : result > 20 ? 'average' : 'poor'} condition',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: sprinklerState ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  double calculateIrrigationValue(
      double rainfall,
      int prediction
      ) {

    final threshold = 50.0;
    double irrigationValue = 120 * (1 - prediction) + (rainfall / threshold) * prediction * 100;
    print('irrigationValue: $irrigationValue');
    // Ensure the irrigation value is within the valid range (0 to 100)
    return irrigationValue.clamp(10.0, 110.0);
  }
}
