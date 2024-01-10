import 'package:irrigation/utils/location.dart';
import 'package:open_meteo/open_meteo.dart';

class WeatherApi {

  Future<Map<String, dynamic>> fetchWeatherForecast(
      {String? lat, String? lon, String? address}) async {

    LocationUtil location = LocationUtil();
    await location.findCoordinates(lat, lon, address);

    return await OpenMeteo(
        latitude: location.latitude!, longitude: location.longitude!, current_weather: true
    ).raw_request(daily: Daily(all: true));
  }
}