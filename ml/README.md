# Smart Irrigation – ML Pipeline

End-to-end machine learning pipeline for autonomous irrigation decisions.

## Architecture

```
Firebase (sensor data)
        │
        ▼
data_pipeline.py  ──►  data/training_data.csv
        │
        ▼
    train.py      ──►  models/best_model.joblib
                        models/scaler.joblib
                        models/label_encoder.joblib
                        models/metrics.json
        │
        ▼
    predict.py    ──►  REST API  (Flask)  or  library
```

## Quickstart

```bash
cd ml
pip install -r requirements.txt

# 1. Generate data  (use --synthetic N if Firebase credentials are not available)
python data_pipeline.py --synthetic 2000

# 2. Train models
python train.py

# 3. Run a quick prediction
python predict.py --moisture 35 --temp 30 --humidity 55 --rain 0

# 4. Start the REST API
python predict.py --serve
```

## REST API

| Method | Path       | Description                          |
|--------|------------|--------------------------------------|
| GET    | `/health`  | Service health & model status        |
| POST   | `/predict` | Make an irrigation prediction        |
| GET    | `/metrics` | Latest training evaluation metrics   |

### POST `/predict` – request body

```json
{
  "soil_moisture": 35.0,
  "temperature": 30.0,
  "humidity": 55.0,
  "rainfall_forecast_mm": 0.0
}
```

### Response

```json
{
  "level": "medium",
  "level_code": 2,
  "confidence": 0.87,
  "reason": "Soil moisture (35.0%) is below optimal ...",
  "auto_irrigate": true,
  "source": "ml_model"
}
```

## Irrigation Levels

| Code | Label    | Auto irrigate | Meaning                              |
|------|----------|---------------|--------------------------------------|
| 0    | `skip`   | ✗             | Rain expected or moisture sufficient |
| 1    | `low`    | ✗             | Light irrigation advised             |
| 2    | `medium` | ✓             | Moderate irrigation needed           |
| 3    | `high`   | ✓             | Critical – irrigate immediately      |

## Firebase credentials

Place your `serviceAccountKey.json` in the `ml/` directory, or set
`FIREBASE_CREDENTIALS_PATH` and `FIREBASE_DATABASE_URL` environment variables.

```bash
export FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com
export FIREBASE_CREDENTIALS_PATH=/path/to/serviceAccountKey.json
python data_pipeline.py          # export real sensor data
```

## Models trained

- **Random Forest** – `sklearn.ensemble.RandomForestClassifier`
- **XGBoost** – `xgboost.XGBClassifier` *(optional – install xgboost)*
- **LightGBM** – `lightgbm.LGBMClassifier` *(optional – install lightgbm)*

The best model (by cross-validated F1-macro) is automatically selected and saved.
