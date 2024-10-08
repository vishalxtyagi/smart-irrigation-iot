import 'package:flutter/material.dart';

class SharedValue extends ChangeNotifier {
  String? _selectedUnit;
  String get selectedUnit => _selectedUnit!;

  void setSelectedUnit(String newSelectedUnit) {
    _selectedUnit = newSelectedUnit;
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
