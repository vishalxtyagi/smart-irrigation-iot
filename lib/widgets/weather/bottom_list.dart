import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irrigation/utils/weather.dart';

class ButtomListView extends StatelessWidget {
  final AsyncSnapshot<Map<String, dynamic>> snapshot;

  const ButtomListView({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '7 - day weather forecast'.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  height: 160,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xff00A1FF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: forecastCard(snapshot.data!, index),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: snapshot.data!["daily"]["weathercode"].length,
            ),
          )
        ],
      ),
    );
  }
}

Widget forecastCard(Map<String, dynamic> data, int index) {
  var dailyData = data['daily'];
  List<dynamic> timeList = dailyData['time'];
  List<dynamic> weatherCode = dailyData['weathercode'];
  List<dynamic> temperatureMinList = dailyData['temperature_2m_min'];
  print('weatherCode: $weatherCode');

  DateTime date = DateTime.fromMillisecondsSinceEpoch(timeList[index] * 1000);
  var dayOfWeek = DateFormat('E').format(date);
  var tempMin = temperatureMinList[index].toStringAsFixed(0);
  var weatherCodeIndex = weatherCode[index];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        '$tempMin °C',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      // You might need to update the way you retrieve the icon based on the weather code.
      // Replace `WeatherUtil.findIcon(...)` with appropriate logic for Open Meteo's icons.
      Image(
        image: AssetImage(
          WeatherUtil.findIcon('${weatherCodeIndex.toString()}', true),
        ),
      ),
      Text(
        dayOfWeek,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      )
    ],
  );
}