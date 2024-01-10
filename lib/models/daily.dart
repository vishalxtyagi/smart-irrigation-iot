class DailyUnits {
  String? time;
  String? weatherCode;
  String? temperature2mMax;
  String? temperature2mMin;
  String? apparentTemperatureMax;
  String? apparentTemperatureMin;
  String? precipitationSum;
  String? rainSum;
  String? precipitationHours;
  String? precipitationProbabilityMax;
  String? windSpeed10mMax;
  String? windDirection10mDominant;

  DailyUnits({
    this.time,
    this.weatherCode,
    this.temperature2mMax,
    this.temperature2mMin,
    this.apparentTemperatureMax,
    this.apparentTemperatureMin,
    this.precipitationSum,
    this.rainSum,
    this.precipitationHours,
    this.precipitationProbabilityMax,
    this.windSpeed10mMax,
    this.windDirection10mDominant,
  });

  factory DailyUnits.fromJson(Map<String, dynamic> json) {
    return DailyUnits(
      time: json['time'],
      weatherCode: json['weathercode'],
      temperature2mMax: json['temperature_2m_max'],
      temperature2mMin: json['temperature_2m_min'],
      apparentTemperatureMax: json['apparent_temperature_max'],
      apparentTemperatureMin: json['apparent_temperature_min'],
      precipitationSum: json['precipitation_sum'],
      rainSum: json['rain_sum'],
      precipitationHours: json['precipitation_hours'],
      precipitationProbabilityMax: json['precipitation_probability_max'],
      windSpeed10mMax: json['windspeed_10m_max'],
      windDirection10mDominant: json['winddirection_10m_dominant'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['weathercode'] = weatherCode;
    data['temperature_2m_max'] = temperature2mMax;
    data['temperature_2m_min'] = temperature2mMin;
    data['apparent_temperature_max'] = apparentTemperatureMax;
    data['apparent_temperature_min'] = apparentTemperatureMin;
    data['precipitation_sum'] = precipitationSum;
    data['rain_sum'] = rainSum;
    data['precipitation_hours'] = precipitationHours;
    data['precipitation_probability_max'] = precipitationProbabilityMax;
    data['windspeed_10m_max'] = windSpeed10mMax;
    data['winddirection_10m_dominant'] = windDirection10mDominant;
    return data;
  }
}

class Daily {
  List<int>? time;
  List<int>? weatherCode;
  List<double>? temperature2mMax;
  List<double>? temperature2mMin;
  List<double>? apparentTemperatureMax;
  List<double>? apparentTemperatureMin;
  List<double>? precipitationSum;
  List<double>? rainSum;
  List<double>? precipitationHours;
  List<int>? precipitationProbabilityMax;
  List<double>? windSpeed10mMax;
  List<int>? windDirection10mDominant;

  Daily({
    this.time,
    this.weatherCode,
    this.temperature2mMax,
    this.temperature2mMin,
    this.apparentTemperatureMax,
    this.apparentTemperatureMin,
    this.precipitationSum,
    this.rainSum,
    this.precipitationHours,
    this.windSpeed10mMax,
    this.windDirection10mDominant,
  });

  factory Daily.fromJson(Map<String, dynamic> json) {
    return Daily(
      time: List<int>.from(json['time']),
      weatherCode: List<int>.from(json['weathercode']),
      temperature2mMax: List<double>.from(json['temperature_2m_max']),
      temperature2mMin: List<double>.from(json['temperature_2m_min']),
      apparentTemperatureMax: List<double>.from(json['apparent_temperature_max']),
      apparentTemperatureMin: List<double>.from(json['apparent_temperature_min']),
      precipitationSum: List<double>.from(json['precipitation_sum']),
      rainSum: List<double>.from(json['rain_sum']),
      precipitationHours: List<double>.from(json['precipitation_hours']),
      windSpeed10mMax: List<double>.from(json['windspeed_10m_max']),
      windDirection10mDominant: List<int>.from(json['winddirection_10m_dominant']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['weathercode'] = weatherCode;
    data['temperature_2m_max'] = temperature2mMax;
    data['temperature_2m_min'] = temperature2mMin;
    data['apparent_temperature_max'] = apparentTemperatureMax;
    data['apparent_temperature_min'] = apparentTemperatureMin;
    data['precipitation_sum'] = precipitationSum;
    data['rain_sum'] = rainSum;
    data['precipitation_hours'] = precipitationHours;
    data['windspeed_10m_max'] = windSpeed10mMax;
    data['winddirection_10m_dominant'] = windDirection10mDominant;
    return data;
  }
}