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

  static getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 200:
        return "Thunderstorm with light rain";
      case 201:
        return "Thunderstorm with rain";
      case 202:
        return "Thunderstorm with heavy rain";
      case 230:
        return "Thunderstorm with light drizzle";
      case 231:
        return "Thunderstorm with drizzle";
      case 232:
        return "Thunderstorm with heavy drizzle";
      case 233:
        return "Thunderstorm with Hail";
      case 300:
        return "Light Drizzle";
      case 301:
        return "Drizzle";
      case 302:
        return "Heavy Drizzle";
      case 500:
        return "Light Rain";
      case 501:
        return "Moderate Rain";
      case 502:
        return "Heavy Rain";
      case 511:
        return "Freezing rain";
      case 520:
        return "Light shower rain";
      case 521:
        return "Shower rain";
      case 522:
        return "Heavy shower rain";
      case 600:
        return "Light snow";
      case 601:
        return "Snow";
      case 602:
        return "Heavy Snow";
      case 610:
        return "Mix snow/rain";
      case 611:
        return "Sleet";
      case 612:
        return "Heavy sleet";
      case 621:
        return "Snow shower";
      case 622:
        return "Heavy snow shower";
      case 623:
        return "Flurries";
      case 700:
        return "Mist";
      case 711:
        return "Smoke";
      case 721:
        return "Haze";
      case 731:
        return "Sand/dust";
      case 741:
        return "Fog";
      case 751:
        return "Freezing Fog";
      case 800:
        return "Clear sky";
      case 801:
        return "Few clouds";
      case 802:
        return "Scattered clouds";
      case 803:
        return "Broken clouds";
      case 804:
        return "Overcast clouds";
      case 900:
        return "Unknown Precipitation";
      default:
        return "Unknown Precipitation";
    }
  }
}