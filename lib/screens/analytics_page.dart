import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:irrigation/widgets/analytics/humidity.dart';
import 'package:irrigation/widgets/analytics/soil_moisture.dart';
import 'package:irrigation/widgets/analytics/temperature.dart';

class AnalyticsPage extends StatefulWidget {
  final Function(bool) isHideBottomNavBar;

  const AnalyticsPage({Key? key, required this.isHideBottomNavBar}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref("FirebaseIOT/68C63AD53478");
  Map<dynamic, dynamic>? firebaseData;

  Map<dynamic, dynamic> _data = {
      'historicalData': {
        'temperature': <SensorData>[],
        'humidity': <SensorData>[],
        'soilMoisture': <SensorData>[],
      },
      'current': 0.0,
      'average': 0.0,
      'highest': 0.0,
      'lowest': 0.0,
    };

  @override
  void initState() {
    super.initState();
    fetchData();
    _databaseReference.keepSynced(true);
    _databaseReference.onValue.listen((DatabaseEvent event) {
      final dynamic snapshotValue = event.snapshot.value;
      if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
        firebaseData = snapshotValue; // Assign Firebase data to firebaseData

        // Fetch data when new data is received
        fetchData();
      } else {
        print('Invalid snapshot value or null data received');
      }

      print(firebaseData);
    });
  }

  Future<void> fetchData() async {
    try {
      if (firebaseData != null) {
        final Map<dynamic, dynamic>? historyData = firebaseData?['history'];
        print('History Data');
        print(historyData);

        if (historyData != null && historyData.isNotEmpty) {
          print('History Data is not empty');
          // Clear existing data before updating
          _clearData();

          // Process the history data
          historyData.forEach((key, value) {
            double timestamp = double.parse(key.toString());
            DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch((timestamp * 1000000).toInt());
            double humidity = double.parse(value['humidity'].toString());
            double soilMoisture = double.parse(value['soilMoisture'].toString());
            double temperature = double.parse(value['temperature'].toString());

            // Update the data for each type (Temperature, Soil Moisture, Humidity)
            _updateData('temperature', dateTime, temperature);
            _updateData('humidity', dateTime, humidity);
            _updateData('soilMoisture', dateTime, soilMoisture);

          });
          print('hdshsf ${historyData.values.toList()}');
        }
      }
    } catch (error) {
      print('Error fetching data: $error');
    }

    setState(() {});
  }

  // Helper method to clear existing data
  void _clearData() {
    _data = {
      'historicalData': {
        'temperature': <SensorData>[],
        'humidity': <SensorData>[],
        'soilMoisture': <SensorData>[],
      },
      'current': 0.0,
      'average': 0.0,
      'highest': 0.0,
      'lowest': 0.0,
    };
  }

  // Helper method to update data for each type (Temperature, Soil Moisture, Humidity)
  void _updateData(String type, DateTime dateTime, double value) {
    List<SensorData> historicalData = _data['historicalData'][type];
    historicalData.add(SensorData(dateTime, value));

    _data['current'] = value;
    _data['average'] = _calculateAverage(historicalData.map((e) => e.value).toList());
    _data['highest'] = _calculateHighest(historicalData.map((e) => e.value).toList());
    _data['lowest'] = _calculateLowest(historicalData.map((e) => e.value).toList());

    print(_data);
  }

  // Helper method to calculate average
  double _calculateAverage(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  // Helper method to calculate highest
  double _calculateHighest(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a > b ? a : b);
  }

  // Helper method to calculate lowest
  double _calculateLowest(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    print(_data);
    final Map<String, Widget> tabs = <String, Widget>{
      'Temperature': Temperature(
        temperatureData: _data['historicalData']['temperature'],
        currentTemperature: _data['current'],
        averageTemperature: _data['average'],
        highestTemperature: _data['highest'],
        lowestTemperature: _data['lowest'],
      ),
      'Soil Moisture': SoilMoisture(
        moistureData: _data['historicalData']['soilMoisture'],
        currentMoisture: _data['current'],
        averageMoisture: _data['average'],
        highestMoisture: _data['highest'],
        lowestMoisture: _data['lowest'],
      ),
      'Humidity': Humidity(
        humidityData: _data['historicalData']['humidity'],
        currentHumidity: _data['current'],
        averageHumidity: _data['average'],
        highestHumidity: _data['highest'],
        lowestHumidity: _data['lowest'],
        isHideBottomNavBar: (value) {
          widget.isHideBottomNavBar(value);
        },
      ),
    };

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: tabs.keys.map((String name) => Tab(text: name)).toList(),
          ),
          title: const Text('Analytics'),
        ),
        body: TabBarView(
          children: tabs.values.toList(),
        ),
      ),
    );
  }
}

class SensorData {
  final DateTime time;
  final double value;

  SensorData(this.time, this.value);
}