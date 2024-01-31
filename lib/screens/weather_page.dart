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
  late String _address;
  Map<String, dynamic>? _weatherData;
  late bool _isLoading;
  late String _error;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _error = '';
    AppPermission.requestLocationPermission();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData({String? address}) async {
    try {
      final data = await WeatherApi().fetchWeatherForecast(address: address);
      setState(() {
        _weatherData = data;
        _isLoading = false;
        _error = '';
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSharedValue();
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Error fetching data';
      });
    }
  }

  void _updateSharedValue() {
    print('Updating shared value weather');

    if (_weatherData != null) {
      Provider.of<SharedValue>(context, listen: false).setRain(_weatherData!['current']['rain']);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _fetchWeatherData();
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
                    _fetchWeatherData(address: _address);
                  });
                }
              },
            )
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _error.isNotEmpty
          ? Center(
        child: Text(
          _error,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            CurrentWeather(snapshot: _weatherData!),
            ButtomListView(snapshot: _weatherData!),
          ],
        ),
      ),
    );
  }
}
