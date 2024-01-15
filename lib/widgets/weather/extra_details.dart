import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExtraDetails extends StatelessWidget {
  final AsyncSnapshot<Map<String, dynamic>> snapshot;

  const ExtraDetails({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    var current = snapshot.data!["current_weather"];

    var windSpeed = current['wind_speed_10m'];
    var humidity = current['relative_humidity_2m'];
    var rain = current['cloud_cover'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Icon(CupertinoIcons.wind, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              "$windSpeed Km/h",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Wind",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        ),
        Column(
          children: [
            const Icon(CupertinoIcons.drop, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              "$humidity %",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Humidity",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        ),
        Column(
          children: [
            const Icon(CupertinoIcons.cloud_rain, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              "$rain %",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Rain",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        )
      ],
    );
  }
}
