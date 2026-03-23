/// Closed-loop automation service.
///
/// Reads the latest sensor data from [SharedValue], evaluates the irrigation
/// recommendation, and writes the pump control command to Firebase when
/// automation is enabled.
library;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:irrigation/models/irrigation_recommendation.dart';
import 'package:irrigation/utils/shared.dart';

class AutomationService {
  final SharedValue _sharedValue;
  final DatabaseReference _db;

  AutomationService(this._sharedValue)
      : _db = FirebaseDatabase.instance.ref('FirebaseIOT');

  /// Evaluate the current conditions and, if automation is enabled, write the
  /// pump command to Firebase.
  ///
  /// Returns the computed [IrrigationRecommendation] regardless of whether
  /// automation is active (so it can be shown in the UI).
  Future<IrrigationRecommendation> evaluate({required String zoneId}) async {
    final soilMoisture = _sharedValue.soilMoisture;
    final rainfall = _sharedValue.rain;

    final recommendation = IrrigationRecommendation.rulesBased(
      soilMoisture: soilMoisture,
      rainfall: rainfall,
    );

    if (_sharedValue.automationEnabled) {
      final command = recommendation.autoIrrigate ? 'ON' : 'OFF';
      try {
        await _db.child(zoneId).child('sprinklers').set(command);
        debugPrint(
            '[Automation] Zone $zoneId → pump $command '
            '(level: ${recommendation.level.label}, '
            'reason: ${recommendation.reason})');
      } catch (e) {
        debugPrint('[Automation] Failed to write pump command: $e');
      }
    }

    return recommendation;
  }
}
