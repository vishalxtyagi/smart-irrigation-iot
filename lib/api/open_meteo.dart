import 'dart:convert';

import 'package:irrigation/utils/location.dart';
import 'package:http/http.dart' as http;

class WeatherApi {

  Future<Map<String, dynamic>> fetchWeatherForecast(
      {String? lat, String? lon, String? address}) async {

    LocationUtil location = LocationUtil();
    await location.findCoordinates(lat, lon, address);
    await location.getAddressFromLatLon();

    // return await OpenMeteo(
    //     latitude: location.latitude!, longitude: location.longitude!, current_weather: true
    // ).raw_request(daily: Daily(all: true), hourly: Hourly(all: true));

    var uri = Uri.https(
        'api.open-meteo.com',
        '/v1/forecast',
        {
          'latitude': location.latitude.toString(),
          'longitude': location.longitude.toString(),
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,precipitation_hours',
          'current': 'temperature_2m,relative_humidity_2m,rain,weather_code,cloud_cover',
          'timezone': 'auto'
        }
    );

    http.Response response = await http.get(uri);
    var data = json.decode(response.body);
    data['address'] = location.address;
    print('data: $data');
    return data;
  }
}