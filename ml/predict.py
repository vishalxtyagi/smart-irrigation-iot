"""
Prediction module for the smart irrigation system.

Can be used:
  1. As a library: ``from predict import IrrigationPredictor``
  2. As a Flask REST API: ``python predict.py``
  3. From the CLI:  ``python predict.py --moisture 40 --temp 28 --humidity 60 --rain 0``

The predictor loads the trained model, scaler, and label encoder once and
then serves requests.  If no trained model exists it falls back to the
rule-based classifier from config.py so the app always gets a result.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
from dataclasses import asdict, dataclass
from typing import Optional

import numpy as np

from config import (
    API_HOST,
    API_PORT,
    FEATURE_COLUMNS,
    IRRIGATION_LABELS,
    LABEL_ENCODER_PATH,
    METRICS_PATH,
    MOISTURE_HIGH_THRESHOLD,
    MOISTURE_MEDIUM_THRESHOLD,
    MOISTURE_SKIP_THRESHOLD,
    MODEL_PATH,
    RAIN_SKIP_THRESHOLD_MM,
    SCALER_PATH,
)

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Result dataclass
# ---------------------------------------------------------------------------

@dataclass
class IrrigationResult:
    level: str                  # "skip" | "low" | "medium" | "high"
    level_code: int             # 0 | 1 | 2 | 3
    confidence: float           # 0.0 – 1.0 (probability of predicted class)
    reason: str                 # human-readable explanation
    auto_irrigate: bool         # True if pump should be turned ON
    source: str                 # "ml_model" | "rule_based"

    def to_dict(self) -> dict:
        return asdict(self)


# ---------------------------------------------------------------------------
# Rule-based fallback (no trained model required)
# ---------------------------------------------------------------------------

def _rule_based_predict(
    soil_moisture: float,
    temperature: float,
    humidity: float,
    rainfall_forecast_mm: float,
) -> IrrigationResult:
    """Deterministic rule-based prediction used as a fallback."""
    if rainfall_forecast_mm >= RAIN_SKIP_THRESHOLD_MM:
        return IrrigationResult(
            level="skip",
            level_code=0,
            confidence=1.0,
            reason=f"Rain forecast of {rainfall_forecast_mm:.1f} mm expected – skipping irrigation.",
            auto_irrigate=False,
            source="rule_based",
        )
    if soil_moisture >= MOISTURE_SKIP_THRESHOLD:
        return IrrigationResult(
            level="skip",
            level_code=0,
            confidence=1.0,
            reason=f"Soil moisture is {soil_moisture:.1f}% – no irrigation needed.",
            auto_irrigate=False,
            source="rule_based",
        )
    if soil_moisture >= MOISTURE_HIGH_THRESHOLD:
        return IrrigationResult(
            level="low",
            level_code=1,
            confidence=1.0,
            reason=f"Soil moisture is {soil_moisture:.1f}% – light irrigation recommended.",
            auto_irrigate=False,
            source="rule_based",
        )
    if soil_moisture >= MOISTURE_MEDIUM_THRESHOLD:
        return IrrigationResult(
            level="medium",
            level_code=2,
            confidence=1.0,
            reason=f"Soil moisture is {soil_moisture:.1f}% – moderate irrigation needed.",
            auto_irrigate=True,
            source="rule_based",
        )
    return IrrigationResult(
        level="high",
        level_code=3,
        confidence=1.0,
        reason=f"Soil moisture is critically low at {soil_moisture:.1f}% – intensive irrigation required.",
        auto_irrigate=True,
        source="rule_based",
    )


# ---------------------------------------------------------------------------
# ML-backed predictor
# ---------------------------------------------------------------------------

class IrrigationPredictor:
    """Loads trained artefacts and serves predictions."""

    def __init__(self) -> None:
        self._model = None
        self._scaler = None
        self._label_encoder = None
        self._load_artefacts()

    def _load_artefacts(self) -> None:
        try:
            import joblib

            self._model = joblib.load(MODEL_PATH)
            self._scaler = joblib.load(SCALER_PATH)
            self._label_encoder = joblib.load(LABEL_ENCODER_PATH)
            logger.info("Loaded trained model from %s", MODEL_PATH)
        except Exception as exc:  # noqa: BLE001
            logger.warning(
                "Could not load trained model (%s). Using rule-based fallback.", exc
            )

    @property
    def model_ready(self) -> bool:
        return self._model is not None

    def predict(
        self,
        soil_moisture: float,
        temperature: float,
        humidity: float,
        rainfall_forecast_mm: float = 0.0,
        day_of_year: Optional[int] = None,
        hour_of_day: Optional[int] = None,
    ) -> IrrigationResult:
        """
        Make an irrigation prediction.

        Falls back to the rule-based classifier if no trained model is available.
        """
        from datetime import datetime

        now = datetime.now()
        if day_of_year is None:
            day_of_year = now.timetuple().tm_yday
        if hour_of_day is None:
            hour_of_day = now.hour

        if not self.model_ready:
            return _rule_based_predict(
                soil_moisture, temperature, humidity, rainfall_forecast_mm
            )

        features = np.array(
            [[soil_moisture, temperature, humidity, rainfall_forecast_mm, day_of_year, hour_of_day]],
            dtype=np.float32,
        )
        features_scaled = self._scaler.transform(features)

        # Predict class and probability
        level_code_enc = int(self._model.predict(features_scaled)[0])
        if hasattr(self._model, "predict_proba"):
            proba = self._model.predict_proba(features_scaled)[0]
            confidence = float(proba[level_code_enc])
        else:
            confidence = 1.0

        # Decode label
        level_code = int(self._label_encoder.inverse_transform([level_code_enc])[0])
        level = IRRIGATION_LABELS.get(level_code, "unknown")

        auto_irrigate = level_code >= 2  # medium or high triggers auto pump
        reason = _build_reason(level, soil_moisture, temperature, rainfall_forecast_mm)

        return IrrigationResult(
            level=level,
            level_code=level_code,
            confidence=confidence,
            reason=reason,
            auto_irrigate=auto_irrigate,
            source="ml_model",
        )


def _build_reason(level: str, soil_moisture: float, temperature: float, rain: float) -> str:
    if level == "skip":
        if rain >= RAIN_SKIP_THRESHOLD_MM:
            return f"Rain forecast ({rain:.1f} mm) is sufficient – skipping irrigation."
        return f"Soil moisture ({soil_moisture:.1f}%) is adequate – no irrigation needed."
    if level == "low":
        return f"Soil moisture ({soil_moisture:.1f}%) is slightly low – light irrigation advised."
    if level == "medium":
        return (
            f"Soil moisture ({soil_moisture:.1f}%) is below optimal and temperature is {temperature:.1f}°C "
            f"– moderate irrigation needed."
        )
    return (
        f"Soil moisture critically low ({soil_moisture:.1f}%) with temperature {temperature:.1f}°C "
        f"– intensive irrigation required immediately."
    )


# ---------------------------------------------------------------------------
# Flask REST API
# ---------------------------------------------------------------------------

def create_app() -> "Flask":  # type: ignore[name-defined]  # noqa: F821
    from flask import Flask, jsonify, request

    app = Flask(__name__)
    predictor = IrrigationPredictor()

    @app.get("/health")
    def health():
        return jsonify(
            {
                "status": "ok",
                "model_ready": predictor.model_ready,
                "model_path": MODEL_PATH if predictor.model_ready else None,
            }
        )

    @app.post("/predict")
    def predict_endpoint():
        data = request.get_json(force=True)
        try:
            result = predictor.predict(
                soil_moisture=float(data["soil_moisture"]),
                temperature=float(data["temperature"]),
                humidity=float(data["humidity"]),
                rainfall_forecast_mm=float(data.get("rainfall_forecast_mm", 0.0)),
                day_of_year=data.get("day_of_year"),
                hour_of_day=data.get("hour_of_day"),
            )
            return jsonify(result.to_dict())
        except (KeyError, TypeError, ValueError) as exc:
            return jsonify({"error": str(exc)}), 400

    @app.get("/metrics")
    def metrics_endpoint():
        if os.path.exists(METRICS_PATH):
            with open(METRICS_PATH, encoding="utf-8") as f:
                return jsonify(json.load(f))
        return jsonify({"error": "No metrics file found. Train a model first."}), 404

    return app


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Smart Irrigation Prediction Service")
    parser.add_argument("--serve", action="store_true", help="Start the Flask API server")
    parser.add_argument("--moisture", type=float, help="Soil moisture %%")
    parser.add_argument("--temp", type=float, help="Temperature °C")
    parser.add_argument("--humidity", type=float, help="Relative humidity %%")
    parser.add_argument("--rain", type=float, default=0.0, help="Rain forecast mm")
    args = parser.parse_args()

    if args.serve:
        app = create_app()
        logger.info("Starting prediction API on %s:%d", API_HOST, API_PORT)
        app.run(host=API_HOST, port=API_PORT)
    elif all(v is not None for v in [args.moisture, args.temp, args.humidity]):
        predictor = IrrigationPredictor()
        result = predictor.predict(
            soil_moisture=args.moisture,
            temperature=args.temp,
            humidity=args.humidity,
            rainfall_forecast_mm=args.rain,
        )
        print(json.dumps(result.to_dict(), indent=2))
    else:
        parser.print_help()
