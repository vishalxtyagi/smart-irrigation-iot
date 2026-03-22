import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:irrigation/models/irrigation_recommendation.dart';
import 'package:irrigation/utils/colors.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:irrigation/utils/shared.dart';
import 'package:provider/provider.dart';

import 'network_detection.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('FirebaseIOT');
  Map<dynamic, dynamic>? firebaseData;
  List<String> units = [];
  String? selectedUnit;
  IrrigationRecommendation? recommendation;
  bool showEmptyState = false;

  @override
  void initState() {
    super.initState();
    initFirebase();
    loadAllUnits();
  }

  Future<void> initFirebase() async {
    _databaseReference = FirebaseDatabase.instance.ref('FirebaseIOT');
  }

  Future<void> listenDb(String unit) async {
    _databaseReference.child(unit).keepSynced(true);
    _databaseReference.child(unit).onValue.listen((DatabaseEvent event) {
      final dynamic snapshotValue = event.snapshot.value;
      if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
        firebaseData = snapshotValue;
        fetchData(unit);
      } else {
        debugPrint('Invalid snapshot value or null data received');
      }
    });
  }

  Future<void> loadAllUnits() async {
    final String? savedUnit = await AppPrefs().getSelectedUnit();
    final devices = await AppPrefs().getDevices();
    setState(() {
      units = List.generate(devices.length, (index) => devices[index]['id']);
      selectedUnit = savedUnit ?? (units.isNotEmpty ? units[0] : null);
      if (selectedUnit != null) {
        fetchData(selectedUnit!);
        listenDb(selectedUnit!);
      }
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

  Future<void> fetchData(String unit) async {
    if (firebaseData == null) {
      setState(() {
        showEmptyState = true;
        recommendation = null;
      });
      return;
    }

    try {
      final current = firebaseData!['current'];
      if (current == null) {
        setState(() {
          showEmptyState = true;
          recommendation = null;
        });
        return;
      }

      final double soilMoisture =
          double.tryParse(current['soilMoisture'].toString()) ?? 0.0;
      final double temperature =
          double.tryParse(current['temperature'].toString()) ?? 0.0;
      final double humidity =
          double.tryParse(current['humidity'].toString()) ?? 0.0;

      // Update shared sensor readings
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Provider.of<SharedValue>(context, listen: false).setSensorReadings(
          soilMoisture: soilMoisture,
          temperature: temperature,
          humidity: humidity,
        );
      });

      final double rain =
          Provider.of<SharedValue>(context, listen: false).rain;

      final rec = IrrigationRecommendation.rulesBased(
        soilMoisture: soilMoisture,
        rainfall: rain,
      );

      setState(() {
        showEmptyState = false;
        recommendation = rec;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Provider.of<SharedValue>(context, listen: false)
            .setRecommendation(rec);
      });
    } catch (e) {
      debugPrint('Error processing prediction data: $e');
      setState(() {
        showEmptyState = true;
        recommendation = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction'),
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
                          firebaseData = null;
                          selectedUnit = value!;
                          AppPrefs().saveSelectedUnit(value);
                          fetchData(selectedUnit!);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset(
                'assets/images/crop_monitoring.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.contain,
              ),
              const Gap(24),
              if (recommendation != null)
                _buildRecommendationCard(recommendation!)
              else if (showEmptyState)
                const Center(
                  child: Text(
                    'No data available.\nAdd a device and ensure it is online.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),
              const Gap(16),
              // Sensor summary
              Consumer<SharedValue>(
                builder: (context, sv, _) {
                  if (sv.soilMoisture == 0 &&
                      sv.temperature == 0 &&
                      sv.humidity == 0) {
                    return const SizedBox.shrink();
                  }
                  return _buildSensorSummary(sv);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(IrrigationRecommendation rec) {
    final Color levelColor;
    final IconData levelIcon;
    switch (rec.level) {
      case IrrigationLevel.skip:
        levelColor = Colors.green;
        levelIcon = Icons.check_circle_rounded;
        break;
      case IrrigationLevel.low:
        levelColor = Colors.lightGreen;
        levelIcon = Icons.water_drop_outlined;
        break;
      case IrrigationLevel.medium:
        levelColor = Colors.orange;
        levelIcon = Icons.water_drop_rounded;
        break;
      case IrrigationLevel.high:
        levelColor = Colors.red;
        levelIcon = Icons.warning_rounded;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(levelIcon, color: levelColor, size: 36),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Irrigation: ${rec.level.label}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: levelColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              rec.reason,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const Gap(12),
            Row(
              children: [
                const Icon(Icons.analytics_outlined, size: 18, color: AppColors.primaryColor),
                const Gap(6),
                Text(
                  'Source: ${rec.source == 'ml_model' ? 'AI Model' : 'Rule-based'}',
                  style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${(rec.confidence * 100).toStringAsFixed(0)}% confidence',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            if (rec.autoIrrigate) ...[
              const Gap(12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.autorenew_rounded,
                        color: Colors.blue, size: 18),
                    Gap(6),
                    Text(
                      'Auto-irrigation will activate the pump',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSensorSummary(SharedValue sv) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Sensor Readings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _sensorChip(
                  Icons.water_drop_rounded,
                  '${sv.soilMoisture.toStringAsFixed(1)}%',
                  'Moisture',
                  sv.soilMoisture < 25 ? Colors.red : AppColors.primaryColor,
                ),
                _sensorChip(
                  Icons.thermostat_rounded,
                  '${sv.temperature.toStringAsFixed(1)}°C',
                  'Temp',
                  AppColors.primaryColor,
                ),
                _sensorChip(
                  Icons.cloud_rounded,
                  '${sv.humidity.toStringAsFixed(1)}%',
                  'Humidity',
                  AppColors.primaryColor,
                ),
                _sensorChip(
                  Icons.umbrella_rounded,
                  '${sv.rain.toStringAsFixed(1)}mm',
                  'Rain',
                  AppColors.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorChip(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const Gap(4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
