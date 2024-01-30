import 'package:flutter/material.dart';

class SharedValue extends ChangeNotifier {
  String? _selectedUnit;
  String get selectedUnit => _selectedUnit!;

  void setSelectedUnit(String newSelectedUnit) {
    _selectedUnit = newSelectedUnit;
    notifyListeners();
  }

  double _temperature = 0.0;
  double get temperature => _temperature;

  void setTemperature(double newTemperature) {
    _temperature = newTemperature;
    notifyListeners();
  }

double _humidity = 0.0;
  double get humidity => _humidity;

  void setHumidity(double newHumidity) {
    _humidity = newHumidity;
    notifyListeners();
  }

double _soilMoisture = 0.0;
  double get soilMoisture => _soilMoisture;

  void setSoilMoisture(double newSoilMoisture) {
    _soilMoisture = newSoilMoisture;
    notifyListeners();
  }

  int _prediction = 0;
  int get prediction => _prediction;

  void setPrediction(int newPrediction) {
    _prediction = newPrediction;
    notifyListeners();
  }

  double _rain = 0.0;
  double get rain => _rain;

  void setRain(double newRain) {
    _rain = newRain;
    notifyListeners();
  }
}
