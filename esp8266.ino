#include "FirebaseESP8266.h"
#include <ESP8266WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <DHT.h>
#include "addons/TokenHelper.h"

// Firebase
#define DATABASE_URL "https://smart-irrigation-pump-default-rtdb.asia-southeast1.firebasedatabase.app"
#define API_KEY "AIzaSyD9ERZ_P7EmjYE4ZOggPbxAn_4UARimUhU"

// PINS
#define DHT_PIN D2
#define LED_PIN D5
#define PUMP_RELAY_PIN D6
#define SOIL_MOISTURE_PIN A0

// Configurability
#define DHT_TYPE DHT11
#define BLINK_DURATION 500
#define MAX_WIFI_CONNECT_ATTEMPTS 20

// Delays
#define WIFI_CONNECT_DELAY 500
#define MONITORING_DELAY 15000

// Offline automation thresholds (used when cloud is unreachable)
#define MOISTURE_LOW_THRESHOLD 30.0
#define MOISTURE_HIGH_THRESHOLD 70.0

// Root Branch
#define ROOT_BRANCH "/FirebaseIOT/"

// Paths (no trailing slash)
#define HEARTBEAT_PATH "/heartbeat"
#define CONTROL_PATH "/control"
#define CURRENT_PATH "/current"
#define HISTORY_PATH "/history"
#define AUTO_PATH "/automation"
#define PUMP_PATH "/sprinklers"


DHT dht(DHT_PIN, DHT_TYPE);
FirebaseData fbdo;
FirebaseData fbdoCtrl;
FirebaseJson fbjo;
FirebaseAuth auth;
FirebaseConfig config;

String deviceId;
String dbPath;
String lastStatus = "OFF";
bool isConnected = false;
bool automationEnabled = false;
unsigned long sendDataPrevMillis = 0;

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");


void setup()
{
  Serial.begin(115200);
  delay(1500);
  Serial.println("Smart Irrigation System\nInitializing...");

  deviceId = WiFi.macAddress();
  deviceId.replace(":", "");

  dbPath = ROOT_BRANCH + deviceId;
  Serial.printf("Device ID: %s\n", deviceId.c_str());

  pinMode(LED_PIN, OUTPUT);
  pinMode(PUMP_RELAY_PIN, OUTPUT);
  pinMode(SOIL_MOISTURE_PIN, INPUT);
  dht.begin();

  // Ensure pump is OFF at startup
  digitalWrite(PUMP_RELAY_PIN, LOW);
  digitalWrite(LED_PIN, LOW);

  isConnected = wifiConnect() || smartConfig();

  timeClient.begin();
  setupFirebase();

  Serial.println("STATUS: Device control - Turned " + lastStatus);
}


void loop()
{
  handleWiFiStatus();
  if (isConnected && Firebase.ready())
  {
    readAutomationFlag();
    if (handleControl() && shouldSendData())
    {
      sendDataPrevMillis = millis();
      updateSensorReadings();
      heartBeat();
    }
  }
  else if (!isConnected)
  {
    // Offline fallback: use local threshold-based automation
    if (shouldSendData())
    {
      sendDataPrevMillis = millis();
      offlineFallbackControl();
    }
  }
  isConnected = (WiFi.status() == WL_CONNECTED);
}


// Read the automation enable flag from Firebase
void readAutomationFlag()
{
  if (Firebase.getBool(fbdoCtrl, dbPath + AUTO_PATH))
  {
    automationEnabled = fbdoCtrl.boolData();
  }
}


// Offline fallback: control pump by raw moisture reading only
void offlineFallbackControl()
{
  float soilMoisture;
  if (!readSoilMoisture(soilMoisture))
    return;

  Serial.printf("[OFFLINE] Soil Moisture: %.2f%%\n", soilMoisture);

  if (soilMoisture < MOISTURE_LOW_THRESHOLD)
  {
    activatePump("ON");
    Serial.println("[OFFLINE] Pump turned ON (low moisture fallback)");
  }
  else if (soilMoisture > MOISTURE_HIGH_THRESHOLD)
  {
    activatePump("OFF");
    Serial.println("[OFFLINE] Pump turned OFF (sufficient moisture)");
  }
}


// Activate or deactivate the pump relay and status LED
void activatePump(String state)
{
  bool pumpOn = (state == "ON");
  digitalWrite(PUMP_RELAY_PIN, pumpOn ? HIGH : LOW);
  digitalWrite(LED_PIN, pumpOn ? HIGH : LOW);
  printControlStatus(state);
}


bool handleControl()
{
  if (Firebase.getString(fbdo, dbPath + PUMP_PATH))
  {
    String controlValue = fbdo.stringData();

    if (controlValue == "ON")
    {
      activatePump("ON");
      return true;
    }
    else if (controlValue == "OFF")
    {
      activatePump("OFF");
    }
    else if (controlValue == "BLOCKED")
    {
      blinkLED(3);
      printControlStatus("BLOCKED");
    }
    return false;
  }

  // Also check legacy control path for backwards compatibility
  if (Firebase.getString(fbdo, dbPath + CONTROL_PATH))
  {
    String controlValue = fbdo.stringData();
    if (controlValue == "ON")
    {
      activatePump("ON");
      return true;
    }
    else if (controlValue == "OFF")
    {
      activatePump("OFF");
    }
  }

  return false;
}


void handleWiFiStatus()
{
  if (WiFi.status() != WL_CONNECTED)
  {
    if (isConnected)
      Serial.println("\nWiFi Disconnected. Reconnecting...");
  }
  else
  {
    if (!isConnected)
      Serial.println("WiFi Reconnected.");
  }
}


bool shouldSendData()
{
  return millis() - sendDataPrevMillis > MONITORING_DELAY || sendDataPrevMillis == 0;
}


unsigned long getTime()
{
  timeClient.update();
  unsigned long now = timeClient.getEpochTime();
  return now;
}


void setupFirebase()
{
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  String email = deviceId + "-device@smartirrigation.net";
  String password = deviceId;
  Serial.printf("Email: %s\n\n", email.c_str());

  auth.user.email = email;
  auth.user.password = password;

  config.token_status_callback = tokenStatusCallback;

  Firebase.begin(&config, &auth);
  Firebase.reconnectNetwork(true);
}


bool wifiConnect()
{
  WiFi.begin();
  Serial.print("\nWiFi Connecting.");
  for (int i = 0; i < MAX_WIFI_CONNECT_ATTEMPTS && WiFi.status() != WL_CONNECTED; ++i)
  {
    Serial.print(".");
    delay(WIFI_CONNECT_DELAY);
  }

  if (WiFi.status() == WL_CONNECTED)
  {
    Serial.println("\nWiFi Connected!");
    printWifiStatus();
    return true;
  }

  Serial.println("\nWifi Connect Failed!");
  return false;
}


bool smartConfig()
{
  WiFi.mode(WIFI_STA);
  WiFi.beginSmartConfig();
  Serial.println("Start SmartConfig.");

  Serial.print("Waiting for SmartConfig. Launch Mobile App (ex: ESP-TOUCH) to progress SmartConfig.");
  while (!WiFi.smartConfigDone())
  {
    Serial.print(".");
    delay(WIFI_CONNECT_DELAY);
  }

  Serial.println("\nSmartConfig done.");

  Serial.print("\nWiFi Connecting.");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(WIFI_CONNECT_DELAY);
  }

  Serial.println("\nWiFi Connected!");
  printWifiStatus();
  return true;
}


void printWifiStatus()
{
  Serial.printf("\nSSID: %s\nIP Address: %s\n",
                WiFi.SSID().c_str(),
                WiFi.localIP().toString().c_str());
}


String generatePassword(int length)
{
  const char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const int charsetSize = sizeof(charset) - 1;

  String password;

  for (int i = 0; i < length; ++i)
  {
    password += charset[random(charsetSize)];
  }

  return password;
}


bool readDHTSensor(float &humidity, float &temperatureInCelcius)
{
  humidity = dht.readHumidity();
  temperatureInCelcius = dht.readTemperature();

  if (isnan(humidity) || isnan(temperatureInCelcius))
  {
    Serial.println("ERROR: DHT Sensor reading failed.");
    return false;
  }

  return true;
}


bool readSoilMoisture(float &soilMoisture)
{
  soilMoisture = 100.00 - (analogRead(SOIL_MOISTURE_PIN) / 1023.00) * 100.00;

  if (isnan(soilMoisture))
  {
    Serial.println("ERROR: Soil Moisture reading failed.");
    return false;
  }

  return true;
}


void updateFirebaseData(const char *path, FirebaseJson value)
{
  if (!Firebase.set(fbdo, dbPath + path, value))
  {
    Serial.printf("ERROR (%s): %s\n", path, fbdo.errorReason().c_str());
  }
}


void updateSensorReadings()
{
  float humidity, temperatureInCelcius, soilMoisture;
  int ts = getTime();

  if (!readDHTSensor(humidity, temperatureInCelcius) || !readSoilMoisture(soilMoisture))
    return;

  Serial.printf("(%d) Humidity: %.2f  Moisture: %.2f  Temperature: %.1f°C\n",
                ts, humidity, soilMoisture, temperatureInCelcius);

  fbjo.clear();

  fbjo.add("humidity", humidity);
  fbjo.add("temperature", temperatureInCelcius);
  fbjo.add("soilMoisture", soilMoisture);

  char historyPath[100];
  sprintf(historyPath, "%s/%d", HISTORY_PATH, ts);
  updateFirebaseData(historyPath, fbjo);

  fbjo.add("lastUpdated", ts);
  updateFirebaseData(CURRENT_PATH, fbjo);
}


void heartBeat()
{
  Firebase.setInt(fbdo, dbPath + HEARTBEAT_PATH, getTime());
}


void blinkLED(int times)
{
  for (int i = 0; i < times; ++i)
  {
    digitalWrite(LED_PIN, HIGH);
    delay(BLINK_DURATION);
    digitalWrite(LED_PIN, LOW);
    delay(BLINK_DURATION);
  }
}


void printControlStatus(String status) {
  if (lastStatus != status) {
    if (status == "BLOCKED")
    {
      Serial.println("ALERT: Your device is currently blocked! Check the admin panel for details.");
    }
    else
    {
      if (lastStatus == "BLOCKED")
        Serial.println("INFO: Your device has been unblocked. Resuming normal operations...");
      Serial.println("STATUS: Device control - Turned " + status);
    }
    lastStatus = status;
  }
}
