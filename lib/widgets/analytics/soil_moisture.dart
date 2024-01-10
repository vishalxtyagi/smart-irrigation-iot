import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SoilMoisture extends StatefulWidget {
  final List<double> moistureData; // List of historical soil moisture data
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
          maxX: widget.moistureData.length.toDouble() - 1,
          minY: widget.lowestMoisture - 5,
          maxY: widget.highestMoisture + 5,
          lineBarsData: [
            LineChartBarData(
              spots: widget.moistureData
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList(),
              isCurved: true,
              color: Colors.green, // Change to green for moisture
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