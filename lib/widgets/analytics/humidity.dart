import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Humidity extends StatefulWidget {
  final Function(bool) isHideBottomNavBar;
  final List<double> humidityData;
  final double currentHumidity;
  final double averageHumidity;
  final double highestHumidity;
  final double lowestHumidity;


  const Humidity({
    required this.humidityData,
    required this.currentHumidity,
    required this.averageHumidity,
    required this.highestHumidity,
    required this.lowestHumidity,
    required this.isHideBottomNavBar,
    super.key,
  });

  @override
  State<Humidity> createState() => _HumidityState();
}

class _HumidityState extends State<Humidity> with AutomaticKeepAliveClientMixin<Humidity> {

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            widget.isHideBottomNavBar(true);
            break;
          case ScrollDirection.reverse:
            widget.isHideBottomNavBar(false);
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Padding(
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
            maxX: widget.humidityData.length.toDouble() - 1,
            minY: widget.lowestHumidity - 5,
            maxY: widget.highestHumidity + 5,
            lineBarsData: [
              LineChartBarData(
                spots: widget.humidityData
                    .asMap()
                    .entries
                    .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                    .toList(),
                isCurved: true,
                color: Colors.blue, // Change to blue for humidity
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}