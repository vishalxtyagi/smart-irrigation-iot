/// Represents the irrigation recommendation produced by the ML model
/// or the rule-based fallback.
library;

enum IrrigationLevel {
  skip,
  low,
  medium,
  high;

  /// Human-readable label for display in the UI.
  String get label {
    switch (this) {
      case IrrigationLevel.skip:
        return 'No Irrigation';
      case IrrigationLevel.low:
        return 'Low';
      case IrrigationLevel.medium:
        return 'Medium';
      case IrrigationLevel.high:
        return 'High';
    }
  }

  /// Returns true if the pump should be activated automatically for this level.
  bool get shouldAutoIrrigate {
    return this == IrrigationLevel.medium || this == IrrigationLevel.high;
  }

  /// Legacy binary mapping: 1 = irrigate, 0 = skip/low.
  int get legacyCode => shouldAutoIrrigate ? 1 : 0;

  static IrrigationLevel fromCode(int code) {
    switch (code) {
      case 0:
        return IrrigationLevel.skip;
      case 1:
        return IrrigationLevel.low;
      case 2:
        return IrrigationLevel.medium;
      case 3:
        return IrrigationLevel.high;
      default:
        return IrrigationLevel.skip;
    }
  }

  static IrrigationLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return IrrigationLevel.low;
      case 'medium':
        return IrrigationLevel.medium;
      case 'high':
        return IrrigationLevel.high;
      default:
        return IrrigationLevel.skip;
    }
  }
}

class IrrigationRecommendation {
  final IrrigationLevel level;
  final double confidence;
  final String reason;
  final bool autoIrrigate;
  final String source;

  const IrrigationRecommendation({
    required this.level,
    required this.confidence,
    required this.reason,
    required this.autoIrrigate,
    required this.source,
  });

  factory IrrigationRecommendation.fromJson(Map<String, dynamic> json) {
    final levelCode = json['level_code'] as int? ?? 0;
    return IrrigationRecommendation(
      level: IrrigationLevel.fromCode(levelCode),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      reason: json['reason'] as String? ?? '',
      autoIrrigate: json['auto_irrigate'] as bool? ?? false,
      source: json['source'] as String? ?? 'rule_based',
    );
  }

  /// Rule-based constructor – used when no backend / model is available.
  factory IrrigationRecommendation.rulesBased({
    required double soilMoisture,
    required double rainfall,
  }) {
    const rainThreshold = 5.0;
    const skipThreshold = 70.0;
    const highThreshold = 55.0;
    const mediumThreshold = 35.0;

    if (rainfall >= rainThreshold) {
      return IrrigationRecommendation(
        level: IrrigationLevel.skip,
        confidence: 1.0,
        reason:
            'Rain forecast of ${rainfall.toStringAsFixed(1)} mm expected – skipping irrigation.',
        autoIrrigate: false,
        source: 'rule_based',
      );
    }
    if (soilMoisture >= skipThreshold) {
      return IrrigationRecommendation(
        level: IrrigationLevel.skip,
        confidence: 1.0,
        reason:
            'Soil moisture is ${soilMoisture.toStringAsFixed(1)}% – no irrigation needed.',
        autoIrrigate: false,
        source: 'rule_based',
      );
    }
    if (soilMoisture >= highThreshold) {
      return IrrigationRecommendation(
        level: IrrigationLevel.low,
        confidence: 1.0,
        reason:
            'Soil moisture is ${soilMoisture.toStringAsFixed(1)}% – light irrigation recommended.',
        autoIrrigate: false,
        source: 'rule_based',
      );
    }
    if (soilMoisture >= mediumThreshold) {
      return IrrigationRecommendation(
        level: IrrigationLevel.medium,
        confidence: 1.0,
        reason:
            'Soil moisture is ${soilMoisture.toStringAsFixed(1)}% – moderate irrigation needed.',
        autoIrrigate: true,
        source: 'rule_based',
      );
    }
    return IrrigationRecommendation(
      level: IrrigationLevel.high,
      confidence: 1.0,
      reason:
          'Soil moisture critically low (${soilMoisture.toStringAsFixed(1)}%) – irrigate immediately.',
      autoIrrigate: true,
      source: 'rule_based',
    );
  }
}
