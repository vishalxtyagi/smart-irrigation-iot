"""
Model training pipeline for the smart irrigation system.

Trains three candidates:
  - Random Forest
  - XGBoost
  - LightGBM

Selects the best-performing model by cross-validated F1-macro score,
saves it with its preprocessing artefacts, and writes evaluation metrics.

Usage
-----
    python train.py                         # uses existing training_data.csv
    python train.py --generate 2000         # regenerate synthetic data first
    python train.py --data path/to/data.csv # custom CSV
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from typing import Any

import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    f1_score,
)
from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler

from config import (
    CV_FOLDS,
    FEATURE_COLUMNS,
    IRRIGATION_LABEL_NAMES,
    LABEL_ENCODER_PATH,
    METRICS_PATH,
    MODEL_PATH,
    RANDOM_STATE,
    SCALER_PATH,
    TARGET_COLUMN,
    TEST_SIZE,
    TRAINING_DATA_PATH,
)

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Candidate model factory
# ---------------------------------------------------------------------------

def _build_candidates() -> dict[str, Any]:
    """Return a dict of {name: unfitted estimator}."""
    candidates: dict[str, Any] = {}

    # Random Forest (always available via scikit-learn)
    candidates["random_forest"] = RandomForestClassifier(
        n_estimators=200,
        max_depth=None,
        min_samples_split=4,
        class_weight="balanced",
        random_state=RANDOM_STATE,
        n_jobs=-1,
    )

    # XGBoost (optional)
    try:
        from xgboost import XGBClassifier

        candidates["xgboost"] = XGBClassifier(
            n_estimators=300,
            max_depth=6,
            learning_rate=0.05,
            subsample=0.8,
            colsample_bytree=0.8,
            use_label_encoder=False,
            eval_metric="mlogloss",
            random_state=RANDOM_STATE,
            n_jobs=-1,
        )
    except ImportError:
        logger.warning("xgboost not installed – skipping XGBClassifier.")

    # LightGBM (optional)
    try:
        from lightgbm import LGBMClassifier

        candidates["lightgbm"] = LGBMClassifier(
            n_estimators=300,
            max_depth=8,
            learning_rate=0.05,
            subsample=0.8,
            colsample_bytree=0.8,
            class_weight="balanced",
            random_state=RANDOM_STATE,
            n_jobs=-1,
            verbose=-1,
        )
    except ImportError:
        logger.warning("lightgbm not installed – skipping LGBMClassifier.")

    return candidates


# ---------------------------------------------------------------------------
# Data loading & preprocessing
# ---------------------------------------------------------------------------

def load_data(csv_path: str) -> tuple[pd.DataFrame, pd.Series]:
    """Load CSV and return (X, y) split."""
    if not os.path.exists(csv_path):
        raise FileNotFoundError(
            f"Training data not found at {csv_path}. "
            "Run data_pipeline.py first (or pass --generate N)."
        )

    df = pd.read_csv(csv_path)
    missing = [c for c in FEATURE_COLUMNS + [TARGET_COLUMN] if c not in df.columns]
    if missing:
        raise ValueError(f"CSV is missing columns: {missing}")

    X = df[FEATURE_COLUMNS]
    y = df[TARGET_COLUMN]
    logger.info(
        "Loaded %d samples, %d features. Label distribution:\n%s",
        len(df),
        len(FEATURE_COLUMNS),
        y.value_counts().sort_index().to_string(),
    )
    return X, y


# ---------------------------------------------------------------------------
# Training & evaluation
# ---------------------------------------------------------------------------

def train(csv_path: str) -> dict[str, Any]:
    """
    Full training run.

    Returns a dict of evaluation metrics for the best model.
    """
    X, y = load_data(csv_path)

    # Encode labels to 0-based integers
    le = LabelEncoder()
    y_enc = le.fit_transform(y)

    # Train / test split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y_enc, test_size=TEST_SIZE, random_state=RANDOM_STATE, stratify=y_enc
    )

    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    candidates = _build_candidates()
    cv = StratifiedKFold(n_splits=CV_FOLDS, shuffle=True, random_state=RANDOM_STATE)

    best_name: str | None = None
    best_cv_score: float = -1.0
    best_model: Any = None
    cv_results: dict[str, float] = {}

    for name, model in candidates.items():
        logger.info("Cross-validating %s ...", name)
        scores = cross_val_score(
            model, X_train_scaled, y_train, cv=cv, scoring="f1_macro", n_jobs=-1
        )
        mean_score = float(scores.mean())
        cv_results[name] = mean_score
        logger.info("  %s CV F1-macro = %.4f ± %.4f", name, mean_score, scores.std())

        if mean_score > best_cv_score:
            best_cv_score = mean_score
            best_name = name
            best_model = model

    assert best_model is not None, "No candidate models available."
    logger.info("Best model: %s (CV F1-macro = %.4f)", best_name, best_cv_score)

    # Final fit on full training set
    best_model.fit(X_train_scaled, y_train)
    y_pred = best_model.predict(X_test_scaled)

    test_acc = accuracy_score(y_test, y_pred)
    test_f1 = f1_score(y_test, y_pred, average="macro")
    report = classification_report(
        y_test, y_pred, target_names=IRRIGATION_LABEL_NAMES, output_dict=True
    )

    logger.info(
        "Test results – accuracy: %.4f  F1-macro: %.4f", test_acc, test_f1
    )
    logger.info(
        "\n%s",
        classification_report(y_test, y_pred, target_names=IRRIGATION_LABEL_NAMES),
    )

    # Persist artefacts
    joblib.dump(best_model, MODEL_PATH)
    joblib.dump(scaler, SCALER_PATH)
    joblib.dump(le, LABEL_ENCODER_PATH)
    logger.info("Saved model to %s", MODEL_PATH)

    metrics: dict[str, Any] = {
        "best_model": best_name,
        "cv_f1_macro": best_cv_score,
        "test_accuracy": test_acc,
        "test_f1_macro": test_f1,
        "classification_report": report,
        "cv_results": cv_results,
        "feature_columns": FEATURE_COLUMNS,
        "label_classes": le.classes_.tolist(),
    }

    with open(METRICS_PATH, "w", encoding="utf-8") as f:
        json.dump(metrics, f, indent=2)
    logger.info("Saved metrics to %s", METRICS_PATH)

    return metrics


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train smart irrigation ML models")
    parser.add_argument(
        "--data",
        type=str,
        default=TRAINING_DATA_PATH,
        help="Path to training CSV (default: data/training_data.csv)",
    )
    parser.add_argument(
        "--generate",
        type=int,
        default=0,
        metavar="N",
        help="Generate N synthetic samples before training",
    )
    args = parser.parse_args()

    if args.generate > 0:
        from data_pipeline import run_pipeline

        run_pipeline(synthetic=args.generate)

    metrics_out = train(args.data)
    print(
        f"\nTraining complete. Best model: {metrics_out['best_model']} "
        f"(test F1-macro: {metrics_out['test_f1_macro']:.4f})"
    )
