"""
Data pipeline for the smart irrigation ML system.

Responsibilities
----------------
1. Export raw sensor readings from Firebase Realtime Database.
2. Merge with optional weather forecast data (open-meteo.com).
3. Generate rule-based irrigation-level labels for supervised training.
4. Save the resulting CSV to data/training_data.csv.

Usage
-----
    python data_pipeline.py                    # export all zones
    python data_pipeline.py --zone AABBCCDD    # single zone
    python data_pipeline.py --synthetic 2000   # generate synthetic dataset
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from datetime import datetime, timezone
from typing import Optional

import numpy as np
import pandas as pd
import requests

from config import (
    DATA_DIR,
    FEATURE_COLUMNS,
    FIREBASE_CREDENTIALS_PATH,
    FIREBASE_DATABASE_URL,
    FIREBASE_ROOT_PATH,
    IRRIGATION_LABELS,
    MOISTURE_HIGH_THRESHOLD,
    MOISTURE_MEDIUM_THRESHOLD,
    MOISTURE_SKIP_THRESHOLD,
    RAIN_SKIP_THRESHOLD_MM,
    TARGET_COLUMN,
    TRAINING_DATA_PATH,
)

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Firebase helpers
# ---------------------------------------------------------------------------

def _init_firebase():
    """Initialise Firebase Admin SDK if not already done."""
    try:
        import firebase_admin
        from firebase_admin import credentials, db

        if not firebase_admin._apps:
            if os.path.exists(FIREBASE_CREDENTIALS_PATH):
                cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
            else:
                # Fall back to application default credentials (GCP / CI)
                cred = credentials.ApplicationDefault()
            firebase_admin.initialize_app(
                cred, {"databaseURL": FIREBASE_DATABASE_URL}
            )
        return db
    except ImportError:
        logger.error("firebase-admin is not installed. Run: pip install firebase-admin")
        sys.exit(1)


def export_from_firebase(zone_id: Optional[str] = None) -> pd.DataFrame:
    """
    Pull history records from Firebase and return as a DataFrame.

    The Firebase path structure is:
        FirebaseIOT/<deviceId>/history/<timestamp>/{humidity, temperature, soilMoisture}
    """
    db = _init_firebase()

    root = db.reference(FIREBASE_ROOT_PATH)

    if zone_id:
        zones_data = {zone_id: root.child(zone_id).get()}
    else:
        zones_data = root.get() or {}

    rows = []
    for zone, zone_val in zones_data.items():
        if not isinstance(zone_val, dict):
            continue
        history = zone_val.get("history", {})
        if not history:
            continue
        for ts_str, reading in history.items():
            if not isinstance(reading, dict):
                continue
            try:
                ts = int(float(ts_str))
                rows.append(
                    {
                        "zone": zone,
                        "timestamp": ts,
                        "soil_moisture": float(reading.get("soilMoisture", 0)),
                        "temperature": float(reading.get("temperature", 0)),
                        "humidity": float(reading.get("humidity", 0)),
                    }
                )
            except (ValueError, TypeError) as exc:
                logger.warning("Skipping record %s: %s", ts_str, exc)

    if not rows:
        logger.warning("No history records found in Firebase.")
        return pd.DataFrame(columns=["zone", "timestamp"] + FEATURE_COLUMNS)

    df = pd.DataFrame(rows)
    df["datetime"] = pd.to_datetime(df["timestamp"], unit="s", utc=True)
    df["day_of_year"] = df["datetime"].dt.dayofyear
    df["hour_of_day"] = df["datetime"].dt.hour
    logger.info("Exported %d records from Firebase.", len(df))
    return df


# ---------------------------------------------------------------------------
# Weather helpers
# ---------------------------------------------------------------------------

def fetch_rainfall_forecast(latitude: float, longitude: float) -> float:
    """
    Fetch today's total rain forecast (mm) from open-meteo.com.
    Returns 0.0 if the request fails.
    """
    try:
        url = "https://api.open-meteo.com/v1/forecast"
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "daily": "rain_sum",
            "timezone": "auto",
            "forecast_days": 1,
        }
        resp = requests.get(url, params=params, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        rain_sum = data.get("daily", {}).get("rain_sum", [0.0])
        return float(rain_sum[0]) if rain_sum else 0.0
    except Exception as exc:  # noqa: BLE001
        logger.warning("Could not fetch rainfall forecast: %s", exc)
        return 0.0


def enrich_with_rainfall(
    df: pd.DataFrame,
    latitude: float = 20.5937,
    longitude: float = 78.9629,
) -> pd.DataFrame:
    """Add a single rainfall_forecast_mm column (same value for every row)."""
    rain = fetch_rainfall_forecast(latitude, longitude)
    df = df.copy()
    df["rainfall_forecast_mm"] = rain
    return df


# ---------------------------------------------------------------------------
# Label generation
# ---------------------------------------------------------------------------

def generate_labels(df: pd.DataFrame) -> pd.DataFrame:
    """
    Derive irrigation level labels using domain rules.

    Rules (in priority order):
    1. Skip  – moisture >= MOISTURE_SKIP_THRESHOLD OR rain >= RAIN_SKIP_THRESHOLD_MM
    2. Low   – moisture >= MOISTURE_HIGH_THRESHOLD
    3. Medium– moisture >= MOISTURE_MEDIUM_THRESHOLD
    4. High  – moisture < MOISTURE_MEDIUM_THRESHOLD
    """
    df = df.copy()

    conditions = [
        (df["soil_moisture"] >= MOISTURE_SKIP_THRESHOLD)
        | (df["rainfall_forecast_mm"] >= RAIN_SKIP_THRESHOLD_MM),
        df["soil_moisture"] >= MOISTURE_HIGH_THRESHOLD,
        df["soil_moisture"] >= MOISTURE_MEDIUM_THRESHOLD,
    ]
    choices = [0, 1, 2]  # skip, low, medium → high is the default (3)
    df[TARGET_COLUMN] = np.select(conditions, choices, default=3)
    return df


# ---------------------------------------------------------------------------
# Synthetic dataset (for testing without a live Firebase instance)
# ---------------------------------------------------------------------------

def generate_synthetic_dataset(n_samples: int = 2000) -> pd.DataFrame:
    """
    Produce a realistic synthetic training dataset.

    Simulates a full agricultural season (365 days × 24 hours) with
    correlated sensor values and weather patterns.
    """
    rng = np.random.default_rng(42)

    # Time axis
    day_of_year = rng.integers(1, 366, size=n_samples)
    hour_of_day = rng.integers(0, 24, size=n_samples)

    # Seasonal temperature: warmer mid-year, cooler at ends
    seasonal_temp = 15 + 15 * np.sin((day_of_year - 80) / 365 * 2 * np.pi)
    temperature = seasonal_temp + rng.normal(0, 3, n_samples)
    temperature = np.clip(temperature, 5, 45)

    # Humidity: inversely correlated with temperature + noise
    humidity = 90 - 0.8 * temperature + rng.normal(0, 8, n_samples)
    humidity = np.clip(humidity, 20, 100)

    # Soil moisture: decays between irrigation events
    soil_moisture = rng.uniform(20, 90, n_samples)

    # Rainfall forecast: mostly 0, occasionally 2–20 mm
    rainfall = np.where(rng.random(n_samples) < 0.15, rng.uniform(2, 20, n_samples), 0.0)

    df = pd.DataFrame(
        {
            "zone": "SYNTHETIC",
            "timestamp": day_of_year * 86400 + hour_of_day * 3600,
            "soil_moisture": soil_moisture,
            "temperature": temperature,
            "humidity": humidity,
            "rainfall_forecast_mm": rainfall,
            "day_of_year": day_of_year,
            "hour_of_day": hour_of_day,
        }
    )
    logger.info("Generated %d synthetic records.", len(df))
    return df


# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------

def run_pipeline(
    zone_id: Optional[str] = None,
    synthetic: int = 0,
    latitude: float = 20.5937,
    longitude: float = 78.9629,
) -> pd.DataFrame:
    """
    End-to-end data pipeline.

    Parameters
    ----------
    zone_id   : limit export to a single zone (None = all zones)
    synthetic : if > 0, generate N synthetic samples instead of querying Firebase
    latitude  : for rainfall forecast enrichment
    longitude : for rainfall forecast enrichment

    Returns the final labelled DataFrame and saves it to TRAINING_DATA_PATH.
    """
    if synthetic > 0:
        df = generate_synthetic_dataset(synthetic)
    else:
        df = export_from_firebase(zone_id)
        if df.empty:
            logger.warning("No data from Firebase; generating synthetic fallback dataset.")
            df = generate_synthetic_dataset(1000)
        else:
            df = enrich_with_rainfall(df, latitude, longitude)

    df = generate_labels(df)

    required_cols = FEATURE_COLUMNS + [TARGET_COLUMN]
    missing = [c for c in required_cols if c not in df.columns]
    if missing:
        raise ValueError(f"Missing columns after pipeline: {missing}")

    out = df[["zone", "timestamp"] + required_cols].copy() if "zone" in df.columns else df[required_cols].copy()
    out.to_csv(TRAINING_DATA_PATH, index=False)
    logger.info("Saved training data to %s (%d rows).", TRAINING_DATA_PATH, len(out))
    return out


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Smart Irrigation Data Pipeline")
    parser.add_argument("--zone", type=str, default=None, help="Firebase zone/device ID")
    parser.add_argument("--synthetic", type=int, default=0, help="Generate N synthetic samples")
    parser.add_argument("--lat", type=float, default=20.5937, help="Latitude for weather data")
    parser.add_argument("--lon", type=float, default=78.9629, help="Longitude for weather data")
    args = parser.parse_args()

    result = run_pipeline(
        zone_id=args.zone,
        synthetic=args.synthetic,
        latitude=args.lat,
        longitude=args.lon,
    )
    print(result[TARGET_COLUMN].value_counts().rename(IRRIGATION_LABELS).to_string())
