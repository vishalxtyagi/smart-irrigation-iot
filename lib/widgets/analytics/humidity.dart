import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../screens/analytics_page.dart';

class Humidity extends StatefulWidget {
  final Function(bool) isHideBottomNavBar;
  final List<SensorData> humidityData;
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

    // from humidityData, show me records that have highest element.time.day in list
    var sensorData = widget.humidityData.where((element) => element.time.day == widget.humidityData.reduce((a, b) => a.time.day > b.time.day ? a : b).time.day).toList();
    sensorData.sort((a, b) => a.time.compareTo(b.time));
    print('Recent data: ${sensorData.map((e) => e.time).toList()}');

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Padding(
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}