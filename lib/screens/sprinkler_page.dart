import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:irrigation/utils/size_config.dart';
import 'package:irrigation/utils/styles.dart';
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
  String selectedUnit = "Unit 1";
  bool isCardView = false;

  @override
  void initState() {
    super.initState();
    initFirebase();
    loadSelectedUnit();
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp();
    _databaseReference = FirebaseDatabase.instance.ref("FirebaseIOT/68C63AD53478")
        .child('sprinklers');
    // Set up a listener for changes in the sprinkler state
    _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        sprinklerState = (data == 'ON');
        isBlocked = (data == 'BLOCKED');
        widget.updateBottomNavBarColor(sprinklerState);
      });
    });
  }

  Future<void> loadSelectedUnit() async {
    String? savedUnit = await AppPrefs().getSelectedUnit();
    if (savedUnit != null) {
      setState(() {
        selectedUnit = savedUnit;
      });
    }
  }

  Future<List<DropdownMenuItem<String>>> _buildDropdownItems() async {
    final deviceCount = await AppPrefs().getDeviceCount();
    final List<String> units = List.generate(deviceCount, (index) => 'Unit ${index + 1}');

    return units.map((value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value, style: const TextStyle(color: Colors.black)),
      );
    }).toList();
  }


  void toggleSprinklerState() {
    // Toggle the sprinkler state in the database
    _databaseReference.set(sprinklerState ? 'OFF' : 'ON');
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              sprinklerState ? 'Sprinklers in progress' : 'Sprinklers are off',
              style: Styles.titleStyle,
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
                ) : SfRadialGauge(
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
                        pointers: const <GaugePointer>[
                          NeedlePointer(
                              needleEndWidth: 5,
                              needleLength: 0.7,
                              value: 82,
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
                )
              ),
            ),
            TextButton(
              onPressed: () {
                if (isBlocked) {
                  return;
                }

                toggleSprinklerState();
              },
              style: Theme.of(context).textButtonTheme.style!.copyWith(
                backgroundColor: MaterialStateProperty.all<Color>(
                  sprinklerState ? Colors.white : AppColors.primaryColor,
                ),
              ),
              child: Text(sprinklerState ? 'Turn off sprinklers' : 'Turn on sprinklers',
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

}
