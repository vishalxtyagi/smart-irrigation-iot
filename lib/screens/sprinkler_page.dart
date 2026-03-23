import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/models/irrigation_recommendation.dart';
import 'package:irrigation/services/automation_service.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:irrigation/utils/shared.dart';
import 'package:irrigation/utils/size_config.dart';
import 'package:irrigation/utils/styles.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
    _databaseReference = FirebaseDatabase.instance.ref('FirebaseIOT');
    loadAllUnits();
  }

  Future<void> listenDb(String unit) async {
    debugPrint('Listening sprinkler for: $unit');
    _databaseReference.child(unit).child('sprinklers').onValue.listen((event) {
      final data = event.snapshot.value;
      debugPrint('Sprinkler state: $data');
      setState(() {
        sprinklerState = (data == 'ON');
        isBlocked = (data == 'BLOCKED');
        widget.updateBottomNavBarColor(sprinklerState);
      });
    });
  }

  Future<void> loadAllUnits() async {
    final String? savedUnit = await AppPrefs().getSelectedUnit();
    final devices = await AppPrefs().getDevices();
    setState(() {
      units = List.generate(devices.length, (index) => devices[index]['id']);
      selectedUnit = savedUnit ?? (units.isNotEmpty ? units[0] : null);
      if (selectedUnit != null) listenDb(selectedUnit!);
    });
  }

  Future<List<DropdownMenuItem<String>>> _buildDropdownItems() async {
    return List.generate(units.length, (index) {
      return DropdownMenuItem<String>(
        value: units[index],
        child: Text('Unit ${index + 1}'),
      );
    });
  }

  void toggleSprinklerState(String unit) {
    _databaseReference.child(unit).child('sprinklers').set(
          sprinklerState ? 'OFF' : 'ON',
        );
  }

  Future<void> _runAutomation(SharedValue sv) async {
    if (selectedUnit == null) return;
    final svc = AutomationService(sv);
    final result = await svc.evaluate(zoneId: selectedUnit!);
    sv.setRecommendation(result);
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
          FutureBuilder(
              future: _buildDropdownItems(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
            const Gap(20),
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
            // Automation toggle row
            _buildAutomationRow(sharedValue),
            Expanded(
              child: Center(
                child: sprinklerState
                    ? Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        padding: const EdgeInsets.all(100),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            'assets/images/logo_white.svg',
                            semanticsLabel: 'Logo',
                            height: 100,
                          ),
                          onPressed: () {},
                        ),
                      )
                    : _buildGauge(
                        sharedValue.rain,
                        sharedValue.prediction,
                      ),              ),
            ),
            // Recommendation reason
            if (sharedValue.recommendation != null && !sprinklerState)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  sharedValue.recommendation!.reason,
                  style: TextStyle(
                    color: sprinklerState ? Colors.white : Colors.grey[700],
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Gap(8),
            TextButton(
              onPressed: () {
                if (isBlocked) return;
                toggleSprinklerState(selectedUnit!);
              },
              style: Theme.of(context).textButtonTheme.style!.copyWith(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      sprinklerState
                          ? Colors.white
                          : AppColors.primaryColor,
                    ),
                  ),
              child: Text(
                sprinklerState ? 'Turn off motor' : 'Turn on motor',
                style: TextStyle(
                  color: sprinklerState ? Colors.black : Colors.white,
                ),
              ),
            ),
            if (isBlocked)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'This device is blocked. Contact your administrator.',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomationRow(SharedValue sv) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: sv.automationEnabled
            ? Colors.blue[50]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: sv.automationEnabled
                ? Colors.blue[200]!
                : Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.autorenew_rounded,
            color: sv.automationEnabled ? Colors.blue : Colors.grey,
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: sv.automationEnabled
                        ? Colors.blue[800]
                        : Colors.grey[700],
                  ),
                ),
                Text(
                  sv.automationEnabled
                      ? 'AI controls the pump automatically'
                      : 'Manual control active',
                  style: TextStyle(
                      fontSize: 12,
                      color: sv.automationEnabled
                          ? Colors.blue[600]
                          : Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: sv.automationEnabled,
            onChanged: (val) {
              sv.setAutomationEnabled(val);
              if (val && selectedUnit != null) {
                _runAutomation(sv);
              }
            },
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildGauge(double rainfall, int prediction) {
    final result = _calculateGaugeValue(rainfall, prediction);

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
          'Based on rainfall: ${rainfall.toStringAsFixed(1)} mm\n'
          'AI Model prediction: $prediction\n\n'
          'Your field is in the ${result > 60 ? 'good' : result > 20 ? 'average' : 'poor'} condition',
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

  double _calculateGaugeValue(double rainfall, int prediction) {
    const threshold = 50.0;
    final gaugeValue =
        120 * (1 - prediction) + (rainfall / threshold) * prediction * 100;
    return gaugeValue.clamp(10.0, 110.0);
  }
}
