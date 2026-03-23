# Smart Irrigation IoT – Autonomous AI-Powered Irrigation System

## Overview

A production-grade, fully autonomous irrigation system that:
- **collects** sensor data (soil moisture, temperature, humidity) from NodeMCU / ESP8266 devices
- **stores** data in Firebase Realtime Database
- **learns** from data using a real ML training pipeline (Random Forest / XGBoost / LightGBM)
- **predicts** irrigation requirements with multi-class output: skip / low / medium / high
- **acts** by automatically turning the pump ON or OFF when automation mode is enabled
- **adapts** with offline fallback control when cloud is unreachable

---

## System Architecture

```
┌───────────────────────────────────────────────────────────────┐
│  NodeMCU / ESP8266 (IoT Firmware)                             │
│  Sensors: DHT11 (temp + humidity), Capacitive Soil Moisture   │
│  Actuator: Pump Relay (D6)                                    │
│  ├─ Cloud mode: reads /sprinklers & /automation from Firebase │
│  └─ Offline fallback: threshold-based pump control           │
└──────────────────────┬────────────────────────────────────────┘
                       │ Firebase Realtime Database
                       │ /FirebaseIOT/<deviceId>/
                       │   current/{soilMoisture, temperature, humidity}
                       │   history/<timestamp>/...
                       │   sprinklers: ON | OFF | BLOCKED
                       │   automation: true | false
                       ▼
┌───────────────────────────────────────────────────────────────┐
│  ML Pipeline (Python – ml/)                                   │
│  data_pipeline.py  → export Firebase data + label generation  │
│  train.py          → Random Forest / XGBoost / LightGBM       │
│  predict.py        → REST API (Flask) + CLI                   │
└───────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────────────────────┐
│  Flutter Mobile App                                           │
│  ├─ Analytics   – charts + Water Usage tab + Alerts          │
│  ├─ Prediction  – low/medium/high recommendation card        │
│  ├─ Weather     – open-meteo.com integration                  │
│  ├─ Motor       – manual control + automation toggle          │
│  └─ Settings    – device management                          │
└───────────────────────────────────────────────────────────────┘
```

---

## Features

| Feature | Status |
|---------|--------|
| Real-time sensor monitoring | ✅ |
| Multi-zone / multi-device support | ✅ |
| Rule-based irrigation recommendation | ✅ |
| ML-backed prediction (RF / XGBoost / LightGBM) | ✅ |
| Multi-class output (skip / low / medium / high) | ✅ |
| Closed-loop automation (auto pump control) | ✅ |
| Skip irrigation when rain expected | ✅ |
| Offline fallback control on device | ✅ |
| Weather forecast integration (open-meteo.com) | ✅ |
| Water usage tracking + alerts | ✅ |
| Historical analytics charts | ✅ |
| Zone-based independent decisions | ✅ |

---

## Repository Structure

```
.
├── esp8266.ino            # NodeMCU / ESP8266 firmware (Arduino IDE)
├── ml/                    # Python ML pipeline
│   ├── config.py          # Shared configuration & thresholds
│   ├── data_pipeline.py   # Firebase export + synthetic generation + labelling
│   ├── train.py           # Model training (RF / XGBoost / LightGBM)
│   ├── predict.py         # Prediction service + Flask REST API
│   ├── requirements.txt   # Python dependencies
│   └── README.md          # ML pipeline documentation
├── lib/
│   ├── models/
│   │   └── irrigation_recommendation.dart  # IrrigationLevel enum + model
│   ├── services/
│   │   └── automation_service.dart         # Closed-loop automation logic
│   ├── screens/
│   │   ├── analytics_page.dart   # Sensor charts + Water Usage + Alerts
│   │   ├── prediction_page.dart  # AI recommendation card
│   │   ├── sprinkler_page.dart   # Pump control + automation toggle
│   │   ├── weather_page.dart     # Weather forecast
│   │   └── settings_page.dart    # Device management
│   └── utils/
│       └── shared.dart           # App-wide state (sensor data, automation, alerts)
└── pubspec.yaml
```

---

## Getting Started

### Hardware

| Component | Pin |
|-----------|-----|
| DHT11 (data) | D2 |
| Pump relay (IN) | D6 |
| Status LED | D5 |
| Soil moisture (analog) | A0 |

### Firmware Setup (Arduino IDE)

1. Install libraries: `FirebaseESP8266`, `DHT sensor library`, `NTPClient`
2. Set `DATABASE_URL` and `API_KEY` in `esp8266.ino`
3. Flash to NodeMCU via Arduino IDE

The firmware:
- Connects to WiFi (with SmartConfig fallback)
- Reads sensors every 15 seconds
- Writes to Firebase: `/FirebaseIOT/<deviceId>/current` and `/history/<ts>`
- Reads `/sprinklers` (pump command) and `/automation` (flag)
- Falls back to local moisture-threshold control when offline

### ML Pipeline

```bash
cd ml
pip install -r requirements.txt

# Generate synthetic training data (or use real Firebase data)
python data_pipeline.py --synthetic 2000

# Train models
python train.py

# Test a prediction
python predict.py --moisture 30 --temp 32 --humidity 50 --rain 0

# Start REST API
python predict.py --serve
```

See [`ml/README.md`](ml/README.md) for full API documentation.

### Flutter App

```bash
flutter pub get
flutter run
```

**App Tabs:**
- **Analytics** – temperature / soil moisture / humidity charts + Water Usage + Alerts
- **Prediction** – irrigation recommendation (skip / low / medium / high) with reason
- **Weather** – live forecast from open-meteo.com
- **Motor** – manual pump toggle + automation on/off switch
- **Settings** – add/manage IoT devices

---

## Automation Logic

When **Automation** is toggled ON in the Motor tab:

1. App reads current soil moisture and rainfall forecast
2. `AutomationService` computes an `IrrigationRecommendation`
3. If level is `medium` or `high` → pump set to `ON`
4. If level is `skip` or `low` → pump stays `OFF`
5. Firmware reads the updated `/sprinklers` value and activates relay

The firmware also implements **offline fallback** (no cloud required):
- Moisture < 30% → pump ON
- Moisture > 70% → pump OFF

---

## License

MIT License – see [LICENSE](LICENSE) for details.
