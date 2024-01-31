import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irrigation/utils/weather.dart';

class ButtomListView extends StatelessWidget {
  final Map<String, dynamic> snapshot;

  const ButtomListView({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
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
            height: 210,
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 125,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xff00A1FF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: forecastCard(snapshot, index),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: snapshot["daily"]["weather_code"].length,
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
  List<dynamic> weatherCode = dailyData['weather_code'];
  List<dynamic> rainList = dailyData['rain_sum'];
  List<dynamic> temperatureMinList = dailyData['temperature_2m_min'];
  print('weatherCode: $weatherCode');

  DateTime date = DateTime.parse(timeList[index]);
  var dayOfWeek = DateFormat('E').format(date);
  var tempMin = temperatureMinList[index].toStringAsFixed(0);
  var weatherCodeIndex = weatherCode[index];
  var rain = rainList[index].toStringAsFixed(0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // You might need to update the way you retrieve the icon based on the weather code.
      // Replace `WeatherUtil.findIcon(...)` with appropriate logic for Open Meteo's icons.
      Image(
        image: AssetImage(
          WeatherUtil.findIcon(weatherCodeIndex),
        ),
        height: 75,
      ),
      const SizedBox(height: 15),
      Text(
        dayOfWeek,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      Text(
        '$tempMin°C / $rain mm',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    ],
  );
}