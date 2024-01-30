import 'package:intl/intl.dart';

class WeatherUtil {
  static String getFormattedDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d').format(dateTime); //Tue, May 5, 2022
  }

  static String findIcon(int code, [bool type = false]) {
    if (type) {
      switch (code) {
        case 0:
          return 'assets/icons/sunny.png';
        case 1:
        case 2:
        case 3:
          return 'assets/icons/snow.png'; // 'partly_cloudy.png';
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
          return 'assets/icons/snow.png'; // 'fog.png';
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 20:
        case 21:
        case 22:
          return 'assets/icons/rainy.png';
        case 15:
        case 16:
        case 17:
        case 18:
        case 23:
        case 24:
          return 'assets/icons/snow_2d.png';
        case 95:
        case 96:
        case 99:
          return 'assets/icons/thunder.png';
        default:
          return 'assets/icons/sunny.png';
      }
    } else {
      switch (code) {
        case 0:
          return 'assets/icons/sunny_2d.png';
        case 1:
        case 2:
        case 3:
          return 'assets/icons/snow_2d.png'; // 'partly_cloudy_2d.png';
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
          return 'assets/icons/snow_2d.png'; // 'fog_2d.png';
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 20:
        case 21:
        case 22:
          return 'assets/icons/rainy_2d.png';
        case 15:
        case 16:
        case 17:
        case 18:
        case 23:
        case 24:
          return 'assets/icons/snow_2d.png';
        case 95:
        case 96:
        case 99:
          return 'assets/icons/thunder_2d.png';
        default:
          return 'assets/icons/sunny_2d.png';
      }
    }
  }


  static String getWeatherDescription(int weatherCode) {

    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 4:
        return 'Fog and depositing rime fog';
      case 5:
        return 'Drizzle: Light intensity';
      case 6:
        return 'Drizzle: Moderate intensity';
      case 7:
        return 'Drizzle: Dense intensity';
      case 8:
        return 'Freezing Drizzle: Light intensity';
      case 9:
        return 'Freezing Drizzle: Dense intensity';
      case 10:
        return 'Rain: Slight intensity';
      case 11:
        return 'Rain: Moderate intensity';
      case 12:
        return 'Rain: Heavy intensity';
      case 13:
        return 'Freezing Rain: Light intensity';
      case 14:
        return 'Freezing Rain: Heavy intensity';
      case 15:
        return 'Snow fall: Slight intensity';
      case 16:
        return 'Snow fall: Moderate intensity';
      case 17:
        return 'Snow fall: Heavy intensity';
      case 18:
        return 'Snow grains';
      case 20:
        return 'Rain showers: Slight intensity';
      case 21:
        return 'Rain showers: Moderate intensity';
      case 22:
        return 'Rain showers: Violent intensity';
      case 23:
        return 'Snow showers: Slight intensity';
      case 24:
        return 'Snow showers: Heavy intensity';
      case 95:
        return 'Thunderstorm: Slight intensity';
      case 96:
        return 'Thunderstorm with slight hail';
      case 99:
        return 'Thunderstorm with heavy hail';
      default:
        return 'Not available';
    }
  }
}