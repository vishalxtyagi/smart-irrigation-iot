import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';

import 'package:irrigation/utils/weather.dart';
import 'package:irrigation/widgets/weather/extra_details.dart';

class CurrentWeather extends StatelessWidget {
  final Map<String, dynamic> snapshot;

  const CurrentWeather({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = snapshot;
    print(data);
    var current = data["current"];
    print(current);
    var temp = current["temperature_2m"].toStringAsFixed(0);
    var formattedDate = DateTime.parse(current["time"]).toLocal();

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
            data["address"] ?? 'N/A',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 370,
            child: Stack(
              children: [
                // Replace WeatherUtil.findIcon with appropriate logic based on new weather codes
                Image(
                  image: AssetImage(
                    WeatherUtil.findIcon(current["weather_code"], true),
                  ),
                  height: 256,
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
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          // Update WeatherUtil.getWeatherDescription based on new weather codes
                          WeatherUtil.getWeatherDescription(current["weather_code"]),
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
          ExtraDetails(snapshot: snapshot), // Ensure ExtraDetails widget handles new data structure
        ],
      ),
    );
  }
}
