import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:irrigation/utils/prefs.dart';
import 'package:irrigation/utils/shared.dart';
import 'package:irrigation/utils/stat_card.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsPage extends StatefulWidget {
  final Function(bool) isHideBottomNavBar;

  const AnalyticsPage({Key? key, required this.isHideBottomNavBar})
      : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('FirebaseIOT');
  Map<dynamic, dynamic>? firebaseData;
  String? selectedUnit;

  Map<String, dynamic> _data = {
    'historicalData': {
      'temperature': <SensorData>[],
      'humidity': <SensorData>[],
      'soilMoisture': <SensorData>[],
    },
    'temperature': {
      'current': 0.0,
      'average': 0.0,
      'highest': 0.0,
      'lowest': 0.0,
    },
    'humidity': {
      'current': 0.0,
      'average': 0.0,
      'highest': 0.0,
      'lowest': 0.0,
    },
    'soilMoisture': {
      'current': 0.0,
      'average': 0.0,
      'highest': 0.0,
      'lowest': 0.0,
    },
  };

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref('FirebaseIOT');
    loadAllUnits();
    fetchData();
  }

  List<String> units = [];

  Future<void> listenDb(String unit) async {
    _clearData();
    _databaseReference.child(unit).keepSynced(true);
    _databaseReference.child(unit).onValue.listen((DatabaseEvent event) {
      final dynamic snapshotValue = event.snapshot.value;
      if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
        firebaseData = snapshotValue;
        fetchData();
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

  Future<void> fetchData() async {
    try {
      if (firebaseData != null) {
        final Map<dynamic, dynamic>? historyData = firebaseData?['history'];

        if (historyData != null && historyData.isNotEmpty) {
          _clearData();

          historyData.forEach((key, value) {
            double timestamp = double.parse(key.toString());
            DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(
                (timestamp * 1000000).toInt());
            double humidity =
                double.parse(value['humidity'].toString());
            double soilMoisture =
                double.parse(value['soilMoisture'].toString());
            double temperature =
                double.parse(value['temperature'].toString());

            _updateData('temperature', dateTime, temperature);
            _updateData('humidity', dateTime, humidity);
            _updateData('soilMoisture', dateTime, soilMoisture);
          });

          // Update shared sensor readings with the latest values
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Provider.of<SharedValue>(context, listen: false).setSensorReadings(
              soilMoisture: _data['soilMoisture']['current'],
              temperature: _data['temperature']['current'],
              humidity: _data['humidity']['current'],
            );
          });
        }
        setState(() {});
      }
    } catch (error) {
      debugPrint('Error fetching data: $error');
    }

    setState(() {});
  }

  void _clearData() {
    _data = {
      'historicalData': {
        'temperature': <SensorData>[],
        'humidity': <SensorData>[],
        'soilMoisture': <SensorData>[],
      },
      'temperature': {
        'current': 0.0,
        'average': 0.0,
        'highest': 0.0,
        'lowest': 0.0,
      },
      'humidity': {
        'current': 0.0,
        'average': 0.0,
        'highest': 0.0,
        'lowest': 0.0,
      },
      'soilMoisture': {
        'current': 0.0,
        'average': 0.0,
        'highest': 0.0,
        'lowest': 0.0,
      },
    };
  }

  void _updateData(String type, DateTime dateTime, double value) {
    List<SensorData> historicalData = _data['historicalData'][type];
    historicalData.add(SensorData(dateTime, value));

    _data[type]['current'] = value;
    _data[type]['average'] =
        _calculateAverage(historicalData.map((e) => e.value).toList());
    _data[type]['highest'] =
        _calculateHighest(historicalData.map((e) => e.value).toList());
    _data[type]['lowest'] =
        _calculateLowest(historicalData.map((e) => e.value).toList());
  }

  double _calculateAverage(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  double _calculateHighest(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a > b ? a : b);
  }

  double _calculateLowest(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Temperature'),
              Tab(text: 'Soil Moisture'),
              Tab(text: 'Humidity'),
              Tab(text: 'Water Usage'),
            ],
          ),
          title: const Text('Analytics'),
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
        body: TabBarView(
          children: [
            _buildChartTab('Temperature',
                _data['historicalData']['temperature'], 'temperature', Icons.thermostat),
            _buildChartTab('Soil Moisture',
                _data['historicalData']['soilMoisture'], 'soilMoisture', Icons.water_drop),
            _buildChartTab('Humidity',
                _data['historicalData']['humidity'], 'humidity', Icons.cloud_rounded),
            _buildWaterUsageTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTab(
      String title, List<SensorData> data, String type, IconData icon) {
    if (data.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const Gap(20.0),
          Text('Fetching $title data...'),
        ],
      ));
    }

    var myData = data
        .where((element) =>
            element.time.day ==
            data
                .reduce((a, b) => a.time.day > b.time.day ? a : b)
                .time
                .day)
        .toList();
    myData.sort((a, b) => a.time.compareTo(b.time));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            primary: true,
            shrinkWrap: true,
            crossAxisCount: 2,
            children: [
              StatCard(
                  title: 'Current',
                  value: _data[type]['current'].toStringAsFixed(2),
                  icon: icon),
              StatCard(
                  title: 'Average',
                  value: _data[type]['average'].toStringAsFixed(2),
                  icon: icon),
              StatCard(
                  title: 'Highest',
                  value: _data[type]['highest'].toStringAsFixed(2),
                  icon: icon),
              StatCard(
                  title: 'Lowest',
                  value: _data[type]['lowest'].toStringAsFixed(2),
                  icon: icon),
            ],
          ),
          const Gap(40.0),
          Text("Today's $title",
              style: const TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.bold)),
          SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat.Hms(),
              intervalType: DateTimeIntervalType.hours,
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: const NumericAxis(
              axisLine: AxisLine(width: 0),
              majorTickLines: MajorTickLines(size: 0),
              minorTickLines: MinorTickLines(size: 0),
              majorGridLines: MajorGridLines(width: 0),
            ),
            series: <CartesianSeries<SensorData, DateTime>>[
              LineSeries<SensorData, DateTime>(
                dataSource: myData,
                xValueMapper: (SensorData sensorData, _) => sensorData.time,
                yValueMapper: (SensorData sensorData, _) => sensorData.value,
                dataLabelSettings:
                    const DataLabelSettings(isVisible: false),
                enableTooltip: true,
                markerSettings: const MarkerSettings(isVisible: false),
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildWaterUsageTab() {
    return Consumer<SharedValue>(
      builder: (context, sv, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Water Usage Summary',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Gap(16),
              GridView.count(
                primary: true,
                shrinkWrap: true,
                crossAxisCount: 2,
                children: [
                  StatCard(
                    title: 'Irrigation Events',
                    value: sv.irrigationEventCount.toString(),
                    icon: Icons.water_drop_rounded,
                  ),
                  StatCard(
                    title: 'Water Used (L)',
                    value:
                        sv.totalWaterUsedLitres.toStringAsFixed(1),
                    icon: Icons.opacity_rounded,
                  ),
                ],
              ),
              const Gap(24),
              const Text(
                'Alerts',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              if (sv.alerts.isEmpty)
                const Text(
                  'No alerts at the moment.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...sv.alerts.reversed.take(20).map(
                      (alert) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.orange[50],
                        child: ListTile(
                          leading: const Icon(Icons.warning_amber_rounded,
                              color: Colors.orange),
                          title: Text(alert),
                        ),
                      ),
                    ),
              if (sv.alerts.isNotEmpty) ...[
                const Gap(8),
                TextButton(
                  onPressed: sv.clearAlerts,
                  child: const Text('Clear all alerts'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class SensorData {
  final DateTime time;
  final double value;

  SensorData(this.time, this.value);
}
