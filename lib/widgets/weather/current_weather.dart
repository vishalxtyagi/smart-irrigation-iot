import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';

import 'package:irrigation/utils/weather.dart';
import 'package:irrigation/widgets/weather/extra_details.dart';

class CurrentWeather extends StatelessWidget {
  final AsyncSnapshot<Map<String, dynamic>> snapshot;

  const CurrentWeather({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    var data = snapshot.data!;
    var current = data["current"];
    var temp = 0;
    // current.temperature2m!.toStringAsFixed(0);
    var formattedDate = DateTime.parse('${current["time"]}');

    return GlowContainer(
      height: MediaQuery.of(context).size.height - 230,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
      glowColor: const Color(0xff00A1FF).withOpacity(0.5),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(60),
        bottomRight: Radius.circular(60),
      ),
      color: const Color(0xff00A1FF),
      spreadRadius: 5,
      child: Column(
        children: [
          GlowText(
            // data.city!,
            'city',
            style: const TextStyle(
              height: 0.1,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          SizedBox(
            height: 430,
            child: Stack(
              children: [
                Image(
                  image: AssetImage(
                    WeatherUtil.findIcon('${current.weatherCode}', true),
                  ),
                  fit: BoxFit.fill,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Column(
                      children: [
                        GlowText(
                          '$temp °C',
                          style: const TextStyle(
                            height: 0.1,
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${WeatherUtil.getWeatherDescription(current.weatherCode!)}',
                          style: const TextStyle(fontSize: 25),
                        ),
                        Text(
                          WeatherUtil.getFormattedDate(formattedDate),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          const Divider(color: Colors.white),
          const SizedBox(height: 10),
          ExtraDetails(snapshot: snapshot),
        ],
      ),
    );
  }
}