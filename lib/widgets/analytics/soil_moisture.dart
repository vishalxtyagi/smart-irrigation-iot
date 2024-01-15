import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irrigation/screens/analytics_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SoilMoisture extends StatefulWidget {
  final List<SensorData> moistureData; // List of historical soil moisture data
  final double currentMoisture;
  final double averageMoisture;
  final double highestMoisture;
  final double lowestMoisture;

  const SoilMoisture({
    required this.moistureData,
    required this.currentMoisture,
    required this.averageMoisture,
    required this.highestMoisture,
    required this.lowestMoisture,
    super.key
  });

  @override
  State<SoilMoisture> createState() => _SoilMoistureState();
}

class _SoilMoistureState extends State<SoilMoisture>
    with AutomaticKeepAliveClientMixin<SoilMoisture> {

  @override
  Widget build(BuildContext context) {

    // from moistureData, show me records that have highest element.time.day in list
    var sensorData = widget.moistureData.where((element) => element.time.day == widget.moistureData.reduce((a, b) => a.time.day > b.time.day ? a : b).time.day).toList();
    sensorData.sort((a, b) => a.time.compareTo(b.time));
    print('Recent data: ${sensorData.map((e) => e.time).toList()}');



    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat.Hms(),
            intervalType: DateTimeIntervalType.hours,
            interval: 1,
          ),
          series: <CartesianSeries>[
            // Renders line chart
            LineSeries<SensorData, DateTime>(
                dataSource: sensorData,
                xValueMapper: (SensorData sensor, _) => sensor.time,
                yValueMapper: (SensorData sensor, _) => sensor.value,
                dataLabelSettings: DataLabelSettings(isVisible: true),

                enableTooltip: true)
          ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}