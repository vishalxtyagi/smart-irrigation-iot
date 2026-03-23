import 'package:flutter/material.dart';
import 'package:irrigation/models/irrigation_recommendation.dart';

class SharedValue extends ChangeNotifier {
  // ── Selected zone / device ──────────────────────────────────────────────
  String? _selectedUnit;
  String get selectedUnit => _selectedUnit ?? '';

  void setSelectedUnit(String newSelectedUnit) {
    _selectedUnit = newSelectedUnit;
    notifyListeners();
  }

  // ── Legacy binary prediction (0 / 1) ────────────────────────────────────
  int _prediction = 0;
  int get prediction => _prediction;

  void setPrediction(int newPrediction) {
    _prediction = newPrediction;
    notifyListeners();
  }

  // ── Weather / rainfall ───────────────────────────────────────────────────
  double _rain = 0.0;
  double get rain => _rain;

  void setRain(double newRain) {
    _rain = newRain;
    notifyListeners();
  }

  // ── Sensor readings (latest) ─────────────────────────────────────────────
  double _soilMoisture = 0.0;
  double get soilMoisture => _soilMoisture;

  double _temperature = 0.0;
  double get temperature => _temperature;

  double _humidity = 0.0;
  double get humidity => _humidity;

  void setSensorReadings({
    required double soilMoisture,
    required double temperature,
    required double humidity,
  }) {
    _soilMoisture = soilMoisture;
    _temperature = temperature;
    _humidity = humidity;

    // Raise low-moisture alert
    if (soilMoisture < 25.0) {
      addAlert('Low moisture alert: ${soilMoisture.toStringAsFixed(1)}%');
    }

    notifyListeners();
  }

  // ── Multi-class irrigation recommendation ────────────────────────────────
  IrrigationRecommendation? _recommendation;
  IrrigationRecommendation? get recommendation => _recommendation;

  void setRecommendation(IrrigationRecommendation rec) {
    _recommendation = rec;
    // Sync legacy binary prediction for backward-compat with SprinklerPage gauge
    _prediction = rec.level.legacyCode;
    notifyListeners();
  }

  // ── Automation ───────────────────────────────────────────────────────────
  bool _automationEnabled = false;
  bool get automationEnabled => _automationEnabled;

  void setAutomationEnabled(bool enabled) {
    _automationEnabled = enabled;
    notifyListeners();
  }

  // ── Alerts ───────────────────────────────────────────────────────────────
  final List<String> _alerts = [];
  List<String> get alerts => List.unmodifiable(_alerts);

  void addAlert(String message) {
    // Avoid duplicate consecutive alerts
    if (_alerts.isNotEmpty && _alerts.last == message) return;
    _alerts.add(message);
    notifyListeners();
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  // ── Water usage tracking ─────────────────────────────────────────────────
  int _irrigationEventCount = 0;
  int get irrigationEventCount => _irrigationEventCount;

  double _totalWaterUsedLitres = 0.0;
  double get totalWaterUsedLitres => _totalWaterUsedLitres;

  /// Called each time an irrigation event ends; [durationSeconds] is how long
  /// the pump ran. Uses a conservative 15 L/min flow-rate estimate.
  void recordIrrigationEvent(int durationSeconds) {
    _irrigationEventCount++;
    _totalWaterUsedLitres += (durationSeconds / 60.0) * 15.0;
    notifyListeners();
  }
}
