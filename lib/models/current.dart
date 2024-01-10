
class CurrentUnits {
  String? time;
  String? interval;
  String? temperature2m;
  String? relativeHumidity2m;
  String? apparentTemperature;
  String? isDay;
  String? precipitation;
  String? rain;
  String? showers;
  String? weatherCode;
  String? cloudCover;
  String? pressureMsl;
  String? surfacePressure;
  String? windSpeed10m;
  String? windDirection10m;
  String? windGusts10m;

  CurrentUnits({
    this.time,
    this.interval,
    this.temperature2m,
    this.relativeHumidity2m,
    this.apparentTemperature,
    this.isDay,
    this.precipitation,
    this.rain,
    this.showers,
    this.weatherCode,
    this.cloudCover,
    this.pressureMsl,
    this.surfacePressure,
    this.windSpeed10m,
    this.windDirection10m,
    this.windGusts10m,
  });

  factory CurrentUnits.fromJson(Map<String, dynamic> json) {
    return CurrentUnits(
      time: json['time'],
      interval: json['interval'],
      temperature2m: json['temperature_2m'],
      relativeHumidity2m: json['relative_humidity_2m'],
      apparentTemperature: json['apparent_temperature'],
      isDay: json['is_day'],
      precipitation: json['precipitation'],
      rain: json['rain'],
      showers: json['showers'],
      weatherCode: json['weathercode'],
      cloudCover: json['cloud_cover'],
      pressureMsl: json['pressure_msl'],
      surfacePressure: json['surface_pressure'],
      windSpeed10m: json['wind_speed_10m'],
      windDirection10m: json['wind_direction_10m'],
      windGusts10m: json['wind_gusts_10m'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['interval'] = interval;
    data['temperature_2m'] = temperature2m;
    data['relative_humidity_2m'] = relativeHumidity2m;
    data['apparent_temperature'] = apparentTemperature;
    data['is_day'] = isDay;
    data['precipitation'] = precipitation;
    data['rain'] = rain;
    data['showers'] = showers;
    data['weathercode'] = weatherCode;
    data['cloud_cover'] = cloudCover;
    data['pressure_msl'] = pressureMsl;
    data['surface_pressure'] = surfacePressure;
    data['wind_speed_10m'] = windSpeed10m;
    data['wind_direction_10m'] = windDirection10m;
    data['wind_gusts_10m'] = windGusts10m;
    return data;
  }
}

class Current {
  int? time;
  int? interval;
  double? temperature2m;
  int? relativeHumidity2m;
  double? apparentTemperature;
  int? isDay;
  double? precipitation;
  double? rain;
  double? showers;
  int? weatherCode;
  int? cloudCover;
  double? pressureMsl;
  double? surfacePressure;
  double? windSpeed10m;
  int? windDirection10m;
  double? windGusts10m;

  Current({
    this.time,
    this.interval,
    this.temperature2m,
    this.relativeHumidity2m,
    this.apparentTemperature,
    this.isDay,
    this.precipitation,
    this.rain,
    this.showers,
    this.weatherCode,
    this.cloudCover,
    this.pressureMsl,
    this.surfacePressure,
    this.windSpeed10m,
    this.windDirection10m,
    this.windGusts10m,
  });

  factory Current.fromJson(Map<String, dynamic> json) {
    return Current(
      time: json['time'],
      interval: json['interval'],
      temperature2m: json['temperature_2m'],
      relativeHumidity2m: json['relative_humidity_2m'],
      apparentTemperature: json['apparent_temperature'],
      isDay: json['is_day'],
      precipitation: json['precipitation'],
      rain: json['rain'],
      showers: json['showers'],
      weatherCode: json['weathercode'],
      cloudCover: json['cloud_cover'],
      pressureMsl: json['pressure_msl'],
      surfacePressure: json['surface_pressure'],
      windSpeed10m: json['wind_speed_10m'],
      windDirection10m: json['wind_direction_10m'],
      windGusts10m: json['wind_gusts_10m'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['interval'] = interval;
    data['temperature_2m'] = temperature2m;
    data['relative_humidity_2m'] = relativeHumidity2m;
    data['apparent_temperature'] = apparentTemperature;
    data['is_day'] = isDay;
    data['precipitation'] = precipitation;
    data['rain'] = rain;
    data['showers'] = showers;
    data['weathercode'] = weatherCode;
    data['cloud_cover'] = cloudCover;
    data['pressure_msl'] = pressureMsl;
    data['surface_pressure'] = surfacePressure;
    data['wind_speed_10m'] = windSpeed10m;
    data['wind_direction_10m'] = windDirection10m;
    data['wind_gusts_10m'] = windGusts10m;
    return data;
  }
}