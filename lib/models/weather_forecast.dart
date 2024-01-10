import 'current.dart';
import 'daily.dart';

class WeatherForecast {
  double? latitude;
  double? longitude;
  String? city;
  double? generationTimeMs;
  int? utcOffsetSeconds;
  String? timezone;
  String? timezoneAbbreviation;
  double? elevation;
  CurrentUnits? currentUnits;
  Current? current;
  DailyUnits? dailyUnits;
  Daily? daily;

  WeatherForecast({
    this.latitude,
    this.longitude,
    this.generationTimeMs,
    this.utcOffsetSeconds,
    this.timezone,
    this.timezoneAbbreviation,
    this.elevation,
    this.currentUnits,
    this.current,
    this.dailyUnits,
    this.daily,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    print('WeatherForecast.fromJson: $json');
    return WeatherForecast(
      latitude: json['latitude'],
      longitude: json['longitude'],
      generationTimeMs: json['generationtime_ms'],
      utcOffsetSeconds: json['utc_offset_seconds'],
      timezone: json['timezone'],
      timezoneAbbreviation: json['timezone_abbreviation'],
      elevation: json['elevation'],
      currentUnits: CurrentUnits.fromJson(json['current_weather_units']),
      current: Current.fromJson(json['current_weather']),
      dailyUnits: DailyUnits.fromJson(json['daily_units']),
      daily: Daily.fromJson(json['daily']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['generationtime_ms'] = generationTimeMs;
    data['utc_offset_seconds'] = utcOffsetSeconds;
    data['timezone'] = timezone;
    data['timezone_abbreviation'] = timezoneAbbreviation;
    data['elevation'] = elevation;
    if (currentUnits != null) {
      data['current_weather_units'] = currentUnits!.toJson();
    }
    if (current != null) {
      data['current_weather'] = current!.toJson();
    }
    if (dailyUnits != null) {
      data['daily_units'] = dailyUnits!.toJson();
    }
    if (daily != null) {
      data['daily'] = daily!.toJson();
    }
    return data;
  }
}