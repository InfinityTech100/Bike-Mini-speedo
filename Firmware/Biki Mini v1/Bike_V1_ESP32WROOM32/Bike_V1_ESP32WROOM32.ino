/**
 * @author Mohamed Maher (m.maher@infinitytech.ltd)
 * @version 1
 * @date 2024-05-1
 * 
 * @copyright Copyright (c) https://www.infinitytech.ltd 2023
 * 
 */
#include <Arduino.h>
#include "BLEDevice.h"
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

#define   RX_PIN        16  // Define the RX pin
#define   TX_PIN        17  // Define the TX pin

/* Define pin assignments for the 7-segment display and common Cathodes */
#define   DATAPIN       14                         // Pin for data signal (IO18/pin30)
#define   CLOCKPIN      12                        // Pin for clock signal (IO19/pin31)
#define   LATCHPIN      13                        // Pin for latch signal (IO21/pin33)
#define   COMMON1PIN    27                      // Pin for common Anode 1 (IO15/pin23)
#define   COMMON2PIN    26                      // Pin for common Anode 2 (IO14/pin13)
#define   MAGIC_WORD    0xFD
#define   LED_0         15
#define   LED_1         5
#define   LED_2         18
#define   LED_3         19
#define   LED_4         4
#define   LED_5         25
#define   FRAME_SIZE    32
#define   LED_R         22
#define   LED_G         21
#define   LED_B         23
#define   BATT_VOLTAGE  35
#define   CHG_STATUS    34
#define   BUTTON_PIN    32  // Define the pin for the button
#define   BUZZER_PIN    33
#define   BUZZER_LOW    80
#define   BUZZER_MID    140
#define   BUZZER_HIGH   255

/* LEDs Flags */
bool LED_1_On = false;
bool LED_2_On = false;
bool LED_3_On = false;
bool LED_4_On = false;
bool LED_5_On = false;
bool buttonState = HIGH;
uint8_t clickCount = 0;

/* Time controle global variables */
uint32_t Tick_counter2 = 0;
uint32_t startTime = millis();
uint32_t timeout = 1000;

/* GPS Module NEO-m6 */
SoftwareSerial gpsSerial(RX_PIN, TX_PIN);  // Create a SoftwareSerial object for GPS module
TinyGPSPlus gps;                           // Create a TinyGPS++ object

/* Function prototype  */
void displayNumber(int number);
void batt_lvl_check(void);
void Buzzer_Freq(uint8_t Buzzer_Pin, uint8_t Freq);

/*  Battery  */
uint8_t prev_batt_percentage = 0;
int batt_val = 0;
uint8_t batt_percentage = 0;
bool firstTime =false;

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
static void notifyCallback(BLERemoteCharacteristic *pBLERemoteCharacteristic, uint8_t *pData, size_t length, bool isNotify) 
{
  Serial.print("Received data from ESP32: ");
  for (int i = 0; i < length; i++) 
  {
    Serial.print(pData[i]);
    Serial.print(" ");
  }
  Serial.println();
  if (length < 3 || pData[0] != MAGIC_WORD) 
  {
    Serial.println("Invalid frame received");
    return;
  }
  uint8_t numObjects = pData[1];
  Serial.print("Number of objects: ");
  Serial.println(numObjects);
  size_t bytesToCopy = min(numObjects * 3, FRAME_SIZE - 3);
  memcpy(Data_Buffer + 3, pData + 2, bytesToCopy);
  // Process distance data for each object
  for (int i = 0; i < numObjects; i++) 
  {
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
class MyClientCallback : public BLEClientCallbacks 
{
  void onConnect(BLEClient *pclient) {}

  void onDisconnect(BLEClient *pclient) {
    connected = false;
    Serial.println("Disconnected from ESP32");
  }
};
class MyAdvertisedDeviceCallbacks : public BLEAdvertisedDeviceCallbacks 
{
  /**
   * Called for each advertising BLE server.
   */
  void onResult(BLEAdvertisedDevice advertisedDevice) 
  {
    Serial.print("BLE Advertised Device found: ");
    Serial.println(advertisedDevice.toString().c_str());

    // Check if the device name is ESP32_BLE
    if (advertisedDevice.getName() == "ESP32 WROOM 32") 
    {
      // Store the address of the ESP32 device
      esp32Address = advertisedDevice.getAddress();
      BLEDevice::getScan()->stop();
      myDevice = new BLEAdvertisedDevice(advertisedDevice);
      doConnect = true;
    }
  }  // onResult
};   // MyAdvertisedDeviceCallbacks
bool connectToServer() 
{
  if (!myDevice) 
  {
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
  if (pRemoteService == nullptr) 
  {
    Serial.print("Failed to find our service UUID: ");
    Serial.println(serviceUUID.toString().c_str());
    pClient->disconnect();
    return false;
  }
  Serial.println(" - Found our service");
  // Obtain a reference to the characteristic in the service of the remote BLE server.
  pRemoteCharacteristic = pRemoteService->getCharacteristic(charUUID);
  if (pRemoteCharacteristic == nullptr) 
  {
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
void setup() 
{
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
  pinMode(BATT_VOLTAGE, INPUT_PULLDOWN);
  pinMode(LED_R, OUTPUT);
  pinMode(LED_G, OUTPUT);
  pinMode(LED_B, OUTPUT);
  digitalWrite(LED_R, LOW);
  digitalWrite(LED_G, LOW);
  digitalWrite(LED_B, LOW);
  pinMode(BUTTON_PIN, INPUT_PULLUP);  
  pinMode(BUZZER_PIN, OUTPUT);        
  /* Blinking LED till BLE connects */
  while(!connectToServer())
  {
    digitalWrite(LED_0,LOW);
    delay(500);
    digitalWrite(LED_0,HIGH);
    delay(500);
  }
  digitalWrite(LED_0,HIGH);
}  // End of setup.
void loop() 
{
  while (gpsSerial.available() > 0) 
  {
    gps.encode(gpsSerial.read());
  }
  if (gps.location.isValid()) 
  {  // Check if GPS data is valid
    /* Convert speed to kilometers per hour */
    int speed = (int)gps.speed.kmph();
    Serial.print(", Speed (km/h): ");
    Serial.println(speed);
    displayNumber(speed);
  } 
  else 
  {
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
  if ((millis() - Tick_counter2) >= 500) 
  {
    // measure battery voltage and change RGB status according to battery level
    batt_lvl_check();
    Tick_counter2 = millis();
  }
  handleButtonPress();
}
void displayNumber(int number) 
{
  int tens = number / 10;
  int units = number % 10;
  // Display tens digit on common Anode 1.
  digitalWrite(LATCHPIN, HIGH);
  digitalWrite(COMMON1PIN, LOW);
  digitalWrite(COMMON2PIN, HIGH);
  for (int i = 7; i >= 0; i--) 
  {
    digitalWrite(DATAPIN, !digits[tens][i]);
    digitalWrite(CLOCKPIN, LOW);
    digitalWrite(CLOCKPIN, HIGH);
  }
  delay(8);
  // Display units digit on common Anode 2.
  digitalWrite(COMMON1PIN, HIGH);
  digitalWrite(COMMON2PIN, LOW);
  for (int i = 7; i >= 0; i--) 
  {
    digitalWrite(DATAPIN, !digits[units][i]);
    digitalWrite(CLOCKPIN, LOW);
    digitalWrite(CLOCKPIN, HIGH);
  }
  // digitalWrite(LATCHPIN, HIGH);
  delay(8);
}
void processDistance(uint8_t distance) 
{
  // Check distance range and set corresponding LED flags
  if (distance >= 0 && distance <= 30 || LED_1_On) 
  {
    LED_1_On = true;
    Serial.println("*******************0:30****************************");
  } 
  else if (distance >= 31 && distance <= 60 || LED_2_On) 
  {
    LED_2_On = true;
    Serial.println("*******************31:60***************************");
  } 
  else if (distance >= 61 && distance <= 90 || LED_3_On) 
  {
    LED_3_On = true;
    Serial.println("*******************61:90***************************");
  } 
  else if (distance >= 91 && distance <= 120 || LED_4_On) 
  {
    LED_4_On = true;
    Serial.println("*******************91:120**************************");
  } 
  else if (distance >= 121 && distance <= 150 || LED_5_On) 
  {
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
void batt_lvl_check(void) 
{
  //get the current
  batt_val = analogRead(BATT_VOLTAGE);
  batt_percentage = map(batt_val, 2620, 4095, 0, 100);
  uint8_t chg_stat = digitalRead(CHG_STATUS);
  if (batt_percentage >= 0 && batt_percentage <= 30) 
  {
    if (chg_stat == HIGH) 
    {
      //toggle led for blinking if it's in charging mode
      digitalWrite(LED_R, !digitalRead(LED_R));
    } 
    else 
    {
      digitalWrite(LED_R, HIGH);
    }
    digitalWrite(LED_G, LOW);
    digitalWrite(LED_B, LOW);
  } 
  else if (batt_percentage > 30 && batt_percentage <= 70) 
  {
    if (chg_stat == HIGH) 
    {
      //toggle led for blinking if it's in charging mode
      digitalWrite(LED_G, !digitalRead(LED_G));
    } 
    else 
    {
      digitalWrite(LED_G, HIGH);
    }
    digitalWrite(LED_R, LOW);
    digitalWrite(LED_B, LOW);
  } 
  else if (batt_percentage > 70 && batt_percentage <= 100) 
  {
    if (chg_stat == HIGH) 
    {
      //toggle led for blinking if it's in charging mode
      digitalWrite(LED_B, !digitalRead(LED_B));
    } 
    else 
    {
      digitalWrite(LED_B, HIGH);
    }
    digitalWrite(LED_R, LOW);
    digitalWrite(LED_G, LOW);
  }
  if ((firstTime) && (batt_percentage > 100 || (abs(prev_batt_percentage - batt_percentage) >= 10))) 
  {
    Serial.println("ERROR READING BATT VOLRAGE!!");
    batt_percentage = prev_batt_percentage;
  } 
  else 
  {
    prev_batt_percentage = batt_percentage;
  }

  Serial.print("Battery Percentage =");
  Serial.println(batt_percentage);

  firstTime = true;
}
void Buzzer_Freq(uint8_t Buzzer_Pin, uint8_t Freq) 
{
  analogWrite(Buzzer_Pin, Freq);
}
void handleButtonPress() 
{
  bool currentButtonState = digitalRead(BUTTON_PIN);
  if (LED_1_On && LED_2_On)
  {
    Buzzer_Freq(BUZZER_PIN, BUZZER_LOW);
  }
  if (currentButtonState == LOW && buttonState == HIGH) 
  {
    delay(50);  // Debounce delay
    if (digitalRead(BUTTON_PIN) == LOW) 
    {
      clickCount++;
      Serial.print("Click count: ");
      Serial.println(clickCount);
      if (clickCount <= 3) 
      {
        switch (clickCount) 
        {
          case 1: Buzzer_Freq(BUZZER_PIN, BUZZER_LOW); break;
          case 2: Buzzer_Freq(BUZZER_PIN, BUZZER_MID); break;
          case 3: Buzzer_Freq(BUZZER_PIN, BUZZER_HIGH); break;
          default: Buzzer_Freq(BUZZER_PIN, 0); break;
        }
      } 
      else 
      {
        clickCount = 0;
      }
    }
  }
  buttonState = currentButtonState;
  delay(100);
}