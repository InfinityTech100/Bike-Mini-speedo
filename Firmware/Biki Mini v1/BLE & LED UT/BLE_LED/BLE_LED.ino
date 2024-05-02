#include "BLEDevice.h"
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

#define RX_PIN 16  // Define the RX pin
#define TX_PIN 17  // Define the TX pin

/* Define pin assignments for the 7-segment display and common Cathodes */
#define DATAPIN 14                         // Pin for data signal (IO18/pin30)
#define CLOCKPIN 12                        // Pin for clock signal (IO19/pin31)
#define LATCHPIN 13                        // Pin for latch signal (IO21/pin33)
#define COMMON1PIN 27                      // Pin for common Anode 1 (IO15/pin23)
#define COMMON2PIN 26                      // Pin for common Anode 2 (IO14/pin13)
#define MAGIC_WORD 0xFD
#define LED_0 15
#define BUZZER_PIN 33
#define LED_1 5
#define LED_2 18
#define LED_3 19
#define LED_4 4
#define LED_5 25
#define FRAME_SIZE 32
bool LED_1_On = false;
bool LED_2_On = false;
bool LED_3_On = false;
bool LED_4_On = false;
bool LED_5_On = false;
SoftwareSerial gpsSerial(RX_PIN, TX_PIN);  // Create a SoftwareSerial object for GPS module
TinyGPSPlus gps;                           // Create a TinyGPS++ object
uint32_t startTime = millis();
uint32_t timeout = 1000;
/* Function prototype to display a number on the 7-segment display */
void displayNumber(int number);

/* Binary representation of each digit from 0 to 9 for the 7-segment display */
int digits[10][8]{
  { 1, 1, 1, 1, 1, 1, 0, 0 },  //dig.0
  { 0, 1, 1, 0, 0, 0, 0, 0 },  //dig.1
  { 1, 1, 0, 1, 1, 0, 1, 0 },  //dig.2
  { 1, 1, 1, 1, 0, 0, 1, 0 },  //dig.3
  { 0, 1, 1, 0, 0, 1, 1, 0 },  //dig.4
  { 1, 0, 1, 1, 0, 1, 1, 0 },  //dig.5
  { 1, 0, 1, 1, 1, 1, 1, 0 },  //dig.6
  { 1, 1, 1, 0, 0, 0, 0, 0 },  //dig.7
  { 1, 1, 1, 1, 1, 1, 1, 0 },  //dig.8
  { 1, 1, 1, 1, 0, 1, 1, 0 },  //dig.9
};

// The remote service we wish to connect to.
static BLEUUID serviceUUID("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
// The characteristic of the remote service we are interested in.
static BLEUUID charUUID("beb5483e-36e1-4688-b7f5-ea07361b26a8");  // Characteristic for receiving data

static boolean doConnect = false;
static boolean connected = false;
static BLERemoteCharacteristic *pRemoteCharacteristic;
static BLEAdvertisedDevice *myDevice = nullptr;
static BLEAddress esp32Address("");
unsigned char Data_Buffer[FRAME_SIZE] = { 0 };
static void notifyCallback(BLERemoteCharacteristic *pBLERemoteCharacteristic, uint8_t *pData, size_t length, bool isNotify) {
  Serial.print("Received data from ESP32: ");
  for (int i = 0; i < length; i++) {
    Serial.print(pData[i]);
    Serial.print(" ");
  }
  Serial.println();
  if (length < 3 || pData[0] != MAGIC_WORD) {
    Serial.println("Invalid frame received");
    return;
  }
  uint8_t numObjects = pData[1];
  Serial.print("Number of objects: ");
  Serial.println(numObjects);
  size_t bytesToCopy = min(numObjects * 3, FRAME_SIZE - 3);
  memcpy(Data_Buffer + 3, pData + 2, bytesToCopy);

  // Process distance data for each object
  for (int i = 0; i < numObjects; i++) {
    uint8_t distance = Data_Buffer[3 + i * 3];
    // Call the function to process distance
    //processDistance(distance);
    Serial.print("Distance : ");
    Serial.println(distance);
    processDistance(distance);
  }
  LED_1_On = false;
  LED_2_On = false;
  LED_3_On = false;
  LED_4_On = false;
  LED_5_On = false;
}

class MyClientCallback : public BLEClientCallbacks {
  void onConnect(BLEClient *pclient) {}

  void onDisconnect(BLEClient *pclient) {
    connected = false;
    Serial.println("Disconnected from ESP32");
  }
};
class MyAdvertisedDeviceCallbacks : public BLEAdvertisedDeviceCallbacks {
  /**
   * Called for each advertising BLE server.
   */
  void onResult(BLEAdvertisedDevice advertisedDevice) {
    Serial.print("BLE Advertised Device found: ");
    Serial.println(advertisedDevice.toString().c_str());

    // Check if the device name is ESP32_BLE
    if (advertisedDevice.getName() == "ESP32 WROOM 32") {
      // Store the address of the ESP32 device
      esp32Address = advertisedDevice.getAddress();
      BLEDevice::getScan()->stop();
      myDevice = new BLEAdvertisedDevice(advertisedDevice);
      doConnect = true;
    }
  }  // onResult
};   // MyAdvertisedDeviceCallbacks

bool connectToServer() {
  if (!myDevice) {
    Serial.println("No device found!");
    return false;
  }

  Serial.print("Forming a connection to ");
  Serial.println(myDevice->getAddress().toString().c_str());

  BLEClient *pClient = BLEDevice::createClient();
  Serial.println(" - Created client");

  pClient->setClientCallbacks(new MyClientCallback());

  // Connect to the remote BLE Server.
  pClient->connect(myDevice);  // if you pass BLEAdvertisedDevice instead of address, it will be recognized type of peer device address (public or private)
  Serial.println(" - Connected to ESP32");

  // Obtain a reference to the service we are after in the remote BLE server.
  BLERemoteService *pRemoteService = pClient->getService(serviceUUID);
  if (pRemoteService == nullptr) {
    Serial.print("Failed to find our service UUID: ");
    Serial.println(serviceUUID.toString().c_str());
    pClient->disconnect();
    return false;
  }
  Serial.println(" - Found our service");

  // Obtain a reference to the characteristic in the service of the remote BLE server.
  pRemoteCharacteristic = pRemoteService->getCharacteristic(charUUID);
  if (pRemoteCharacteristic == nullptr) {
    Serial.print("Failed to find our characteristic UUID: ");
    Serial.println(charUUID.toString().c_str());
    pClient->disconnect();
    return false;
  }
  Serial.println(" - Found our characteristic");

  // Register notification callback
  if (pRemoteCharacteristic->canNotify())
    pRemoteCharacteristic->registerForNotify(notifyCallback);

  connected = true;
  return true;
}

void setup() {
  Serial.begin(115200);
  gpsSerial.begin(9600);  // Initialize GPS serial communication
  pinMode(DATAPIN, OUTPUT);
  pinMode(LATCHPIN, OUTPUT);
  pinMode(CLOCKPIN, OUTPUT);
  pinMode(COMMON1PIN, OUTPUT);
  pinMode(COMMON2PIN, OUTPUT);
  Serial.println("Starting Arduino BLE Client application...");
  BLEDevice::init("");
  // Retrieve a Scanner and set the callback we want to use to be informed when we
  // have detected a new device.  Specify that we want active scanning and start the
  // scan to run for 5 seconds.
  BLEScan *pBLEScan = BLEDevice::getScan();
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setInterval(1349);
  pBLEScan->setWindow(449);
  pBLEScan->setActiveScan(true);
  pBLEScan->start(5, false);
  pinMode(LED_0,  OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT); 
  pinMode(LED_1, OUTPUT);
  pinMode(LED_2, OUTPUT);
  pinMode(LED_3, OUTPUT);
  pinMode(LED_4, OUTPUT);
  pinMode(LED_5, OUTPUT);
  digitalWrite(LED_0, HIGH);
  digitalWrite(LED_1, HIGH);
  digitalWrite(LED_2, HIGH);
  digitalWrite(LED_3, HIGH);
  digitalWrite(LED_4, HIGH);
  digitalWrite(LED_5, HIGH);
  while(!connectToServer())
  {
    digitalWrite(LED_0,LOW);
    delay(500);
    digitalWrite(LED_0,HIGH);
    delay(500);
  }
  digitalWrite(LED_0,HIGH);

}  // End of setup.


void loop() {
  while (gpsSerial.available() > 0) 
  {
    gps.encode(gpsSerial.read());
  }
  if (gps.location.isValid()) {  // Check if GPS data is valid
    /* Convert speed to kilometers per hour */
    int speed = (int)gps.speed.kmph();
    Serial.print(", Speed (km/h): ");
    Serial.println(speed);
    displayNumber(speed);
  } else {
    displayNumber(0);
    Serial.println("No GPS data available");
  }
  // if (gps.location.isUpdated()) {
  //   // Print latitude, longitude, and speed
  //   Serial.print("Latitude: ");
  //   Serial.print(gps.location.lat(), 8);
  //   Serial.print(", Longitude: ");
  //   Serial.print(gps.location.lng(), 8);
  // }                              // Check for new GPS data

}
void displayNumber(int number) {
  int tens = number / 10;
  int units = number % 10;
  // Display tens digit on common Anode 1.
  digitalWrite(LATCHPIN, HIGH);
  digitalWrite(COMMON1PIN, LOW);
  digitalWrite(COMMON2PIN, HIGH);
  for (int i = 7; i >= 0; i--) {
        digitalWrite(DATAPIN, !digits[tens][i]);
        digitalWrite(CLOCKPIN, LOW);
        digitalWrite(CLOCKPIN, HIGH);
  }
  delay(8);
  // Display units digit on common Anode 2.
  digitalWrite(COMMON1PIN, HIGH);
  digitalWrite(COMMON2PIN, LOW);
  for (int i = 7; i >= 0; i--) {
    digitalWrite(DATAPIN, !digits[units][i]);
    digitalWrite(CLOCKPIN, LOW);
    digitalWrite(CLOCKPIN, HIGH);
  }
  // digitalWrite(LATCHPIN, HIGH);
  delay(8);
}
void processDistance(uint8_t distance) {
  // Check distance range and set corresponding LED flags
  if (distance >= 0 && distance <= 30 || LED_1_On) {
    LED_1_On = true;
    Serial.println("*******************0:30*************************");
  } else if (distance >= 31 && distance <= 60 || LED_2_On) {
    LED_2_On = true;
    Serial.println("*******************31:60*************************");
  } else if (distance >= 61 && distance <= 90 || LED_3_On) {
    LED_3_On = true;
    Serial.println("*******************61:90*************************");
  } else if (distance >= 91 && distance <= 120 || LED_4_On) {
    LED_4_On = true;
    Serial.println("*******************91:120*************************");
  } else if (distance >= 121 && distance <= 150 || LED_5_On) {
    LED_5_On = true;
    Serial.println("*******************121:150*************************");
  }
  // Update LED states
  digitalWrite(LED_1, LED_1_On ? LOW : HIGH);
  digitalWrite(LED_2, LED_2_On ? LOW : HIGH);
  digitalWrite(LED_3, LED_3_On ? LOW : HIGH);
  digitalWrite(LED_4, LED_4_On ? LOW : HIGH);
  digitalWrite(LED_5, LED_5_On ? LOW : HIGH);
}
