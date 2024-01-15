
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irrigation/screens/analytics_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Temperature extends StatefulWidget {
  final List<SensorData> temperatureData;
  final double currentTemperature;
  final double averageTemperature;
  final double highestTemperature;
  final double lowestTemperature;

  const Temperature({
    required this.temperatureData,
    required this.currentTemperature,
    required this.averageTemperature,
    required this.highestTemperature,
    required this.lowestTemperature,
    super.key,
  });

  @override
  State<Temperature> createState() => _TemperatureState();
}

class _TemperatureState extends State<Temperature>
    with AutomaticKeepAliveClientMixin<Temperature> {

  @override
  Widget build(BuildContext context) {

    // from temperatureData, show me records that have highest element.time.day in list
    var sensorData = widget.temperatureData.where((element) => element.time.day == widget.temperatureData.reduce((a, b) => a.time.day > b.time.day ? a : b).time.day).toList();
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