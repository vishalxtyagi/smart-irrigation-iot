import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation/api/open_meteo.dart';
import 'package:irrigation/models/weather_forecast.dart';
import 'package:irrigation/screens/search_city.dart';
import 'package:irrigation/widgets/weather/bottom_list.dart';
import 'package:irrigation/widgets/weather/current_weather.dart';
import 'package:irrigation/utils/permission.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xff030317),
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
                CupertinoIcons.location_circle,
                color: Colors.white,
                size: 30,
              ),
            ),
            const Row(
              children: [
                Icon(CupertinoIcons.map_fill, color: Colors.white),
                Text(
                  'open-meteo.com',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
      body: ListView(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: weatherObj,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    CurrentWeather(snapshot: snapshot),
                    ButtomListView(snapshot: snapshot),
                  ],
                );
              } else {
                return const Center(
                    child: Text(
                      'City not found\n Please enter correct city',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                      textAlign: TextAlign.center,
                    ));
              }
            },
          ),
        ],
      ),
    );
  }
}
