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
    var current = snapshot.data!["current"];
    var current_units = snapshot.data!["current_units"];

    print('current: $current');

    var rain = '${current['rain']} ${current_units['rain']}';
    var relative_humidity_2m = '${current['relative_humidity_2m']} ${current_units['relative_humidity_2m']}';
    var cloud_cover = '${current['cloud_cover']} ${current_units['cloud_cover']}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Icon(CupertinoIcons.cloud_rain_fill, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              rain,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Rain",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        ),
        Column(
          children: [
            const Icon(Icons.water, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              relative_humidity_2m,
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
            const Icon(CupertinoIcons.cloud_fill, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              cloud_cover,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Cloud",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        )
      ],
    );
  }
}
