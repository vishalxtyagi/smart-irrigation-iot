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
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  Map<String, dynamic> _data = {
    'Temperature': {
      'historicalData': <double>[],
      'current': 0.0,
      'average': 0.0,
      'highest': 0.0,
      'lowest': 0.0,
    },
    'Soil Moisture': {
      'historicalData': <double>[],
      'current': 0.0,
      'average': 0.0,
      'highest': 0.0,
      'lowest': 0.0,
    },
    'Humidity': {
      'historicalData': <double>[],
      'current': 0.0,
      'average': 0.0,
      'highest': 0.0,
      'lowest': 0.0,
    },
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DatabaseEvent event = await _databaseReference.once();
      Map<dynamic, dynamic> firebaseData = event.snapshot.value;

      if (firebaseData != null) {
        List<dynamic> historyData = firebaseData['history'];

        if (historyData != null && historyData.isNotEmpty) {
          // Clear existing data before updating
          _clearData();

          // Process the history data
          historyData.forEach((entry) {
            double timestamp = entry['timestamp'] ?? 0.0;
            double humidity = entry['humidity'] ?? 0.0;
            double soilMoisture = entry['soilMoisture'] ?? 0.0;
            double temperature = entry['temperature'] ?? 0.0;

            // Update the data for each type (Temperature, Soil Moisture, Humidity)
            _updateData('Temperature', timestamp, temperature);
            _updateData('Soil Moisture', timestamp, soilMoisture);
            _updateData('Humidity', timestamp, humidity);
          });
        }
      }
    } catch (error) {
      print('Error fetching data: $error');
    }

    setState(() {});
  }

  // Helper method to clear existing data
  void _clearData() {
    _data.forEach((key, value) {
      value['historicalData'] = <double>[];
      value['current'] = 0.0;
      value['average'] = 0.0;
      value['highest'] = 0.0;
      value['lowest'] = 0.0;
    });
  }

  // Helper method to update data for each type (Temperature, Soil Moisture, Humidity)
  void _updateData(String type, double timestamp, double value) {
    List<double> historicalData = _data[type]['historicalData'];
    historicalData.add(value);

    _data[type]['current'] = value;
    _data[type]['average'] = _calculateAverage(historicalData);
    _data[type]['highest'] = _calculateHighest(historicalData);
    _data[type]['lowest'] = _calculateLowest(historicalData);
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
    final Map<String, Widget> tabs = <String, Widget>{
      'Temperature': Temperature(
        temperatureData: _data['Temperature']['historicalData'],
        currentTemperature: _data['Temperature']['current'],
        averageTemperature: _data['Temperature']['average'],
        highestTemperature: _data['Temperature']['highest'],
        lowestTemperature: _data['Temperature']['lowest'],
      ),
      'Soil Moisture': SoilMoisture(
        moistureData: _data['Soil Moisture']['historicalData'],
        currentMoisture: _data['Soil Moisture']['current'],
        averageMoisture: _data['Soil Moisture']['average'],
        highestMoisture: _data['Soil Moisture']['highest'],
        lowestMoisture: _data['Soil Moisture']['lowest'],
      ),
      'Humidity': Humidity(
        humidityData: _data['Humidity']['historicalData'],
        currentHumidity: _data['Humidity']['current'],
        averageHumidity: _data['Humidity']['average'],
        highestHumidity: _data['Humidity']['highest'],
        lowestHumidity: _data['Humidity']['lowest'],
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
