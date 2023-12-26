import 'package:flutter/material.dart';
import 'package:irrigation/widgets/analytics/humidity.dart';
import 'package:irrigation/widgets/analytics/soil_moisture.dart';
import 'package:irrigation/widgets/analytics/temperature.dart';

class AnalyticsPage extends StatelessWidget {
  final Function(bool) isHideBottomNavBar;

  const AnalyticsPage({super.key, required this.isHideBottomNavBar});

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget> tabs = <String, Widget>{
      'Temperature': const Temperature(),
      'Soil Moisture': const SoilMoisture(),
      'Humidity': Humidity(
        isHideBottomNavBar: (value) {
          isHideBottomNavBar(value);
        },
      ),
    };

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: tabs.keys.map((String name) => Tab(text: name)).toList(),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: tabs.values.toList(),
        ),
      ),
    );
  }
}