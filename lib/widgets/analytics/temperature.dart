import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Temperature extends StatefulWidget {
  final List<double> temperatureData;
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
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: 0,
          maxX: widget.temperatureData.length.toDouble() - 1,
          minY: widget.lowestTemperature - 5,
          maxY: widget.highestTemperature + 5,
          lineBarsData: [
            LineChartBarData(
              spots: widget.temperatureData
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList(),
              isCurved: true,
              color: Colors.red,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}