import 'package:intl/intl.dart';

class WeatherUtil {
  static String getFormattedDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d').format(dateTime); //Tue, May 5, 2022
  }

  static String findIcon(String name, bool type) {
    if (type) {
      switch (name) {
        case "Clouds":
          return "assets/icons/sunny.png";
        case "Rain":
          return "assets/icons/rainy.png";
        case "Drizzle":
          return "assets/icons/rainy.png";
        case "Thunderstorm":
          return "assets/icons/thunder.png";
        case "Snow":
          return "assets/icons/snow.png";
        default:
          return "assets/icons/sunny.png";
      }
    } else {
      switch (name) {
        case "Clouds":
          return "assets/icons/sunny_2d.png";
        case "Rain":
          return "assets/icons/rainy_2d.png";
        case "Drizzle":
          return "assets/icons/rainy_2d.png";
        case "Thunderstorm":
          return "assets/icons/thunder_2d.png";
        case "Snow":
          return "assets/icons/snow_2d.png";
        default:
          return "assets/icons/sunny_2d.png";
      }
    }
  }


  static String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return "Clear sky";
      case 1:
        return "Mainly clear sky";
      case 2:
        return "Partly cloudy";
      case 3:
        return "Overcast sky";
      case 45:
        return "Fog";
      case 48:
        return "Depositing rime fog";
      case 51:
        return "Drizzle: Light intensity";
      case 53:
        return "Drizzle: Moderate intensity";
      case 55:
        return "Drizzle: Dense intensity";
      case 56:
        return "Freezing Drizzle: Light intensity";
      case 57:
        return "Freezing Drizzle: Dense intensity";
      case 61:
        return "Rain: Slight drizzle";
      case 63:
        return "Rain: Moderate drizzle";
      case 65:
        return "Rain: Heavy drizzle";
      case 66:
        return "Freezing Rain: Light intensity";
      case 67:
        return "Freezing Rain: Heavy intensity";
      case 71:
        return "Snow fall: Slight";
      case 73:
        return "Snow fall: Moderate";
      case 75:
        return "Snow fall: Heavy";
      case 77:
        return "Snow grains";
      case 80:
        return "Rain showers: Slight";
      case 81:
        return "Rain showers: Moderate";
      case 82:
        return "Rain showers: Heavy";
      case 85:
        return "Snow showers: Slight";
      case 86:
        return "Snow showers: Heavy";
      case 95:
        return "Thunderstorm: Slight";
      case 96:
        return "Thunderstorm: Moderate";
      case 99:
        return "Thunderstorm: Heavy hail";
      default:
        return "Unknown Precipitation";
    }
  }
}