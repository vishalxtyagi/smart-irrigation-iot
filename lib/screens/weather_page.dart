import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation/api/open_meteo.dart';
import 'package:irrigation/screens/search_city.dart';
import 'package:irrigation/utils/shared.dart';
import 'package:irrigation/widgets/weather/bottom_list.dart';
import 'package:irrigation/widgets/weather/current_weather.dart';
import 'package:irrigation/utils/permission.dart';
import 'package:provider/provider.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Future<Map<String, dynamic>> weatherObj;
  late String _address;

  @override
  void initState() {
    super.initState();
    AppPermission.requestLocationPermission();
    weatherObj = WeatherApi().fetchWeatherForecast();
  }

  @override
  Widget build(BuildContext context) {
    final sharedValue = Provider.of<SharedValue>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff00A1FF),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  weatherObj = WeatherApi().fetchWeatherForecast();
                });
              },
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const Row(
              children: [
                Icon(CupertinoIcons.map_fill, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'open-meteo.com',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            ),
            GestureDetector(
              child: const Icon(
                Icons.search_outlined,
                color: Colors.white,
                size: 30,
              ),
              onTap: () async {
                var tappedName = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return const SearchCity();
                    }));
                if (tappedName != null) {
                  setState(() {
                    _address = tappedName;
                    weatherObj = WeatherApi().fetchWeatherForecast(
                      address: _address,
                    );
                  });
                }
              },
            )
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: weatherObj,
        builder: (context, snapshot) {
          print(snapshot);

          if (snapshot.hasData) {
            print(snapshot.data);
            sharedValue.setRain(snapshot.data!['current']['rain']);
            return SingleChildScrollView(
              child: Column(
                children: [
                  CurrentWeather(snapshot: snapshot),
                  ButtomListView(snapshot: snapshot),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error fetching data',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
