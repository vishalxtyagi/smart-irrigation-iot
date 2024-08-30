# IoT-Based Smart Irrigation System

## Project Overview

This project is an IoT-based Smart Irrigation System that allows monitoring and control of environmental factors such as temperature, humidity, and soil moisture in real-time. The system is built using NodeMCU, various sensors (humidity, soil moisture, temperature), and Firebase Realtime Database for data storage and retrieval. The data collected from the sensors is visualized in a Flutter-based mobile application, providing users with insights into the environmental conditions of their agricultural fields or gardens.

Additionally, the application integrates a Support Vector Machine (SVM) model to predict irrigation needs based on the sensor data and external weather conditions. A visual meter in the app shows the irrigation level, helping users make informed decisions about watering.

## Features

- **Real-time Monitoring**: Continuously monitors temperature, humidity, and soil moisture levels.
- **Data Visualization**: Historical and current sensor data are visualized in charts and statistical summaries within a Flutter app.
- **SVM-Based Prediction**: An SVM model predicts the irrigation requirement based on sensor data and weather conditions.
- **Irrigation Level Meter**: A visual meter displays the predicted irrigation level, guiding users on when and how much to irrigate.
- **Multi-Unit Support**: Monitor multiple units or sections of a field with distinct sensor setups.
- **Firebase Integration**: Sensor data is stored and retrieved from Firebase Realtime Database, ensuring data is accessible from anywhere.
- **User-Friendly UI**: A Flutter-based app with an intuitive UI for easy interaction and data interpretation.

## Project Structure

### Hardware Components

- **NodeMCU**: Microcontroller used for connecting the sensors to the internet.
- **DHT11/DHT22 Sensor**: For measuring temperature and humidity.
- **Soil Moisture Sensor**: For measuring the soil moisture content.
- **Relay Module**: For controlling the water pump based on the soil moisture level.
- **Power Supply**: To power the NodeMCU and sensors.

### Software Components

1. **NodeMCU Firmware (Arduino IDE)**:
    - The NodeMCU is programmed using the Arduino IDE.
    - Connects to the Wi-Fi and sends sensor data to Firebase Realtime Database.
    - Fetches data from DHT11/DHT22 (temperature and humidity) and soil moisture sensor.
    - Controls the water pump based on soil moisture levels.

2. **Firebase Realtime Database**:
    - Stores sensor data in real-time.
    - Provides a central location for data storage, accessible from the Flutter app.

3. **Flutter Mobile Application**:
    - **AnalyticsPage**: A dashboard that visualizes temperature, humidity, and soil moisture data.
    - **SVM-Based Prediction**: Integrates a Support Vector Machine (SVM) model to predict the irrigation requirement.
    - **Irrigation Level Meter**: Displays the predicted irrigation level based on current and forecasted weather conditions.
    - **Real-time Updates**: The app listens for changes in the Firebase database and updates the UI accordingly.
    - **Multi-Unit Support**: Users can select different units (fields or sections) to monitor.

### SVM Model Integration

The SVM model in the app predicts whether irrigation is needed based on sensor data and weather conditions. The prediction is binary (yes/no) or categorical (low, medium, high) depending on the model's training. The prediction is then reflected in the app's UI, guiding the user to make informed irrigation decisions.

#### Model Features:
- **Input Variables**: 
  - Soil Moisture Level
  - Ambient Temperature
  - Humidity Level
  - External Weather Conditions (e.g., Rain forecast, Cloud cover)
  
- **Output**:
  - Predicted irrigation requirement level.
  
- **Visualization**:
  - The app displays a meter (like a speedometer) that visually represents the predicted irrigation level. The meter's color and position change based on the SVM model's prediction, making it easy for users to understand the current irrigation needs.

### Irrigation Level Meter

- The **Irrigation Level Meter** is a visual gauge that provides a quick view of the recommended irrigation level.
- **Green Zone**: Indicates optimal moisture levels—no immediate irrigation needed.
- **Yellow Zone**: Indicates moderate need—consider irrigation based on future weather conditions.
- **Red Zone**: Indicates a high need for irrigation—immediate action required.

The meter dynamically adjusts based on:
- **Sensor Data**: Real-time values of soil moisture, temperature, and humidity.
- **Weather Forecast**: Predicts future weather conditions (e.g., rain, sun) that could affect irrigation needs.

## Getting Started

### Prerequisites

- **Hardware**:
  - NodeMCU (ESP8266)
  - DHT11/DHT22 Sensor
  - Soil Moisture Sensor
  - Relay Module
  - Water Pump (optional)
  - Jumper Wires
  - Breadboard
  - Power Supply

- **Software**:
  - Arduino IDE
  - Flutter SDK
  - Firebase Account
  - Android Studio (or any IDE for Flutter development)
  - SVM Model (trained using relevant sensor data and weather conditions)

### Hardware Setup

1. **Connect the DHT11/DHT22 Sensor** to the NodeMCU:
    - VCC to 3.3V
    - GND to GND
    - Data Pin to D4 (or any other GPIO pin)

2. **Connect the Soil Moisture Sensor** to the NodeMCU:
    - VCC to 3.3V
    - GND to GND
    - Analog Output Pin to A0

3. **Relay Module and Water Pump**:
    - Connect the relay module to control the water pump.
    - VCC to 3.3V
    - GND to GND
    - IN to D1 (or any other GPIO pin)

4. **Power the NodeMCU** using a USB cable or external power supply.

### Software Setup

#### 1. Arduino IDE
- Install the ESP8266 board in Arduino IDE.
- Install necessary libraries:
  - `FirebaseESP8266`
  - `DHT sensor library`
- Upload the firmware code to NodeMCU.

```cpp
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <DHT.h>

#define FIREBASE_HOST "your-firebase-app.firebaseio.com"
#define FIREBASE_AUTH "your-database-secret"
#define WIFI_SSID "your-SSID"
#define WIFI_PASSWORD "your-PASSWORD"
#define DHTPIN D4
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);
FirebaseData firebaseData;

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  dht.begin();
}

void loop() {
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  int soilMoistureValue = analogRead(A0);

  Firebase.setFloat(firebaseData, "/your-unit-id/temperature", t);
  Firebase.setFloat(firebaseData, "/your-unit-id/humidity", h);
  Firebase.setInt(firebaseData, "/your-unit-id/soilMoisture", soilMoistureValue);

  delay(2000);
}
```

#### 2. Firebase Setup
- Create a Firebase project.
- Set up Firebase Realtime Database.
- Enable authentication (optional, for securing database access).
- Add your Firebase credentials to the NodeMCU code.

#### 3. Flutter Mobile Application

1. **Setup Firebase in Flutter**:
    - Add `firebase_core`, `firebase_database`, `provider`, and `syncfusion_flutter_charts` dependencies in `pubspec.yaml`.
    - Initialize Firebase in your Flutter app.

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^1.10.6
  firebase_database: ^9.1.7
  provider: ^6.0.3
  syncfusion_flutter_charts: ^20.3.58
  intl: ^0.17.0
```

2. **Integrate SVM Model**:
    - Train an SVM model using historical sensor data and weather conditions.
    - Integrate the trained model into the Flutter app.
    - Use the model's predictions to update the Irrigation Level Meter in the app.

3. **Run the Flutter App**:
    - Ensure your Android/iOS device is connected.
    - Run `flutter pub get` to install dependencies.
    - Start the app using `flutter run`.

### Usage

- **Monitor Data**: Open the app to monitor real-time temperature, humidity, and soil moisture data.
- **Switch Units**: Use the dropdown in the app to switch between different units (fields or sections) if you have multiple setups.
- **SVM Predictions**: View the predicted irrigation needs based on sensor data and weather conditions.
- **Irrigation Level Meter**: Use the meter to guide irrigation decisions, ensuring optimal soil moisture levels.

## Folder Structure

```bash
.
├── android
├── ios
├── lib
│   ├── utils
│   │   ├── prefs.dart      # Shared preferences management
│   │   ├── shared.dart     # Shared utility functions
│   │   └── stat_card.dart  # UI widget for statistics display
│   ├── analytics_page.dart #

 Main page for analytics
│   ├── svm_model.dart      # SVM model integration
│   ├── meter_widget.dart   # UI widget for Irrigation Level Meter
│   └── main.dart           # Entry point of the Flutter app
├── test
├── pubspec.yaml            # Flutter project dependencies
└── README.md               # Project documentation
```

## Troubleshooting

- **Firebase Connection Issues**: Ensure the Firebase database URL and authentication key are correctly set in both the NodeMCU and Flutter app.
- **Sensor Data Not Displaying**: Double-check the wiring of your sensors and ensure they are correctly connected to the NodeMCU.
- **App Crashes**: Review the Flutter console logs for any error messages and ensure all dependencies are correctly installed.
- **SVM Model Predictions**: If the model predictions seem inaccurate, retrain the model with updated data and ensure the input features are correctly pre-processed.

## Future Enhancements

- **Add Notifications**: Notify users when the soil moisture is below a certain threshold or when irrigation is needed.
- **Automated Irrigation**: Implement automatic control of the water pump based on the SVM model's predictions.
- **Data Export**: Provide options to export data for further analysis.
- **Remote Control**: Allow remote control of the irrigation system from the app.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
