import 'dart:convert';
import 'dart:developer';

import 'package:irrigation/models/weather_forecast_daily.dart';
import 'package:irrigation/utils/location.dart';
import 'package:http/http.dart' as http;

class WeatherApi {
  Future<WeatherForecast> fetchWeatherForecast(
      {String? cityName, bool? isCity}) async {
    Location location = Location();
    await location.getCurrentLocation();

    Map<String, String?> parameters;

    if (isCity == true) {
      var queryParameters = {
        'units': 'metric',
        'q': cityName,
      };

      parameters = queryParameters;
    } else {
      var queryParameters = {
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
      };

      parameters = queryParameters;
    }

    var uri = Uri.https(
      "api.open-meteo.com",
      "/v1/forecast",
      parameters,
    );

    log('request: ${uri.toString()}');

    var response = await http.get(uri);

    print('response: ${response.body}');

    if (response.statusCode == 200) {
      return WeatherForecast.fromJson(json.decode(response.body));
    } else {
      throw Future.error('Error response');
    }
  }
}