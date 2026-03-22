"""
Central configuration for the smart irrigation ML pipeline.
"""

# ---------------------------------------------------------------------------
# Feature definitions
# ---------------------------------------------------------------------------

# Input feature names expected by every model
FEATURE_COLUMNS = [
    "soil_moisture",
    "temperature",
    "humidity",
    "rainfall_forecast_mm",
    "day_of_year",
    "hour_of_day",
]

# Target column produced by the label generation step
TARGET_COLUMN = "irrigation_level"

# ---------------------------------------------------------------------------
# Irrigation level labels
# ---------------------------------------------------------------------------

IRRIGATION_LABELS = {
    0: "skip",    # no irrigation needed (e.g. rain expected or moisture high)
    1: "low",     # light irrigation
    2: "medium",  # moderate irrigation
    3: "high",    # intensive irrigation
}

IRRIGATION_LABEL_NAMES = list(IRRIGATION_LABELS.values())

# ---------------------------------------------------------------------------
# Rule-based thresholds (used for label generation and automation decisions)
# ---------------------------------------------------------------------------

MOISTURE_SKIP_THRESHOLD = 70.0      # % — no irrigation needed above this
MOISTURE_HIGH_THRESHOLD = 55.0      # % — only low irrigation needed above this
MOISTURE_MEDIUM_THRESHOLD = 35.0    # % — medium irrigation below this
RAIN_SKIP_THRESHOLD_MM = 5.0        # mm — skip irrigation if rain forecast >= this

# ---------------------------------------------------------------------------
# Model training
# ---------------------------------------------------------------------------

RANDOM_STATE = 42
TEST_SIZE = 0.2
CV_FOLDS = 5

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")
MODEL_DIR = os.path.join(BASE_DIR, "models")

os.makedirs(DATA_DIR, exist_ok=True)
os.makedirs(MODEL_DIR, exist_ok=True)

TRAINING_DATA_PATH = os.path.join(DATA_DIR, "training_data.csv")
MODEL_PATH = os.path.join(MODEL_DIR, "best_model.joblib")
SCALER_PATH = os.path.join(MODEL_DIR, "scaler.joblib")
LABEL_ENCODER_PATH = os.path.join(MODEL_DIR, "label_encoder.joblib")
METRICS_PATH = os.path.join(MODEL_DIR, "metrics.json")

# ---------------------------------------------------------------------------
# Firebase (populated via .env or environment variables)
# ---------------------------------------------------------------------------

FIREBASE_DATABASE_URL = os.getenv(
    "FIREBASE_DATABASE_URL",
    "https://smart-irrigation-pump-default-rtdb.asia-southeast1.firebasedatabase.app",
)
FIREBASE_CREDENTIALS_PATH = os.getenv("FIREBASE_CREDENTIALS_PATH", "serviceAccountKey.json")
FIREBASE_ROOT_PATH = "FirebaseIOT"

# ---------------------------------------------------------------------------
# Prediction API server
# ---------------------------------------------------------------------------

API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "5000"))
