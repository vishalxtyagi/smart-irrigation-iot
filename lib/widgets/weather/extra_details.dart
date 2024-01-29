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

    print('current: $current');

    var windSpeed = current['windspeed'];
    var isDay = current['is_day'];
    var windDirection = current['winddirection'];

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
            const Icon(CupertinoIcons.location_north_fill, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              "$windDirection",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Wind Direction",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        ),
        Column(
          children: [
            const Icon(CupertinoIcons.sun_max_fill, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              isDay == 1 ? "Day" : "Night",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Day/Night",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        )
      ],
    );
  }
}
