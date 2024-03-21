#include <Arduino.h>
#include <BLEDevice.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>

#define   FRAME_SIZE          32
#define   LED_PIN             15
#define   BUZZER_PIN          33
#define   LED_1               19
#define   LED_2               18
#define   LED_3               5
#define   LED_4               4
#define   LED_5               25
#define   MAGIC_WORD          0xFD
#define   BUTTON_PIN          32 // Define the pin for the button
#define   BUZZER_PIN          33 // Define the pin for the buzzer
#define   BUZZER_LOW          80
#define   BUZZER_MID          140
#define   BUZZER_HIGH         255
/* Define TX and RX pins for SoftwareSerial */ 
#define   GPS_RX_PIN          16   /* Pin for GPS RX signal IO16 */
#define   GPS_TX_PIN          17   /* Pin for GPS TX signal IO17 */

/* Define pin assignments for the 7-segment display and common Cathodes */ 
#define   CLOCKPIN            12   /* Pin for clock signal IO12 */ 
#define   LATCHPIN            13   /* Pin for latch signal IO13 */  
#define   DATAPIN             14   /* Pin for data  signal IO14 */ 

#define   COMMON1PIN          26   /* Pin for common cathode DIG1_EN IO26 */ 
#define   COMMON2PIN          27   /* Pin for common cathode DIG2_EN IO27 */

/*********************************************************************/
#define   RED_LED_PIN         23
#define   GREEN_LED_PIN       22
#define   BLUE_LED_PIN        21
#define   BATTERY_INPUT_PIN   35

bool BLE_dataReceive = false;
// Initialize the click count
uint8_t clickCount = 0; 
// Track the previous state of the button
bool buttonState = HIGH; 
//LED Flags 
bool LED_1_On = false;
bool LED_2_On = false;
bool LED_3_On = false;
bool LED_4_On = false;
bool LED_5_On = false;
/* Create a TinyGPS++ object */ 
TinyGPSPlus gps;

/* Define SoftwareSerial object for GPS communication */
SoftwareSerial gpsSerial(GPS_RX_PIN, GPS_TX_PIN);

// Functions prototype 
void displayNumber(int number);
void Buzzer_Freq (uint8_t Buzzer_Pin,uint8_t Freq);
// Binary representation of each digit from 0 to 9 for the 7-segment display
const byte segments[] = 
{
  B00111111, // 0
  B00000110, // 1
  B01011011, // 2
  B01001111, // 3
  B01100110, // 4
  B01101101, // 5
  B01111101, // 6
  B00000111, // 7
  B01111111, // 8
  B01101111  // 9
};

// The remote service we wish to connect to.
static BLEUUID serviceUUID("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
// The characteristic of the remote service we are interested in.
static BLEUUID charUUID("beb5483e-36e1-4688-b7f5-ea07361b26a8");

static boolean doConnect = false;
static boolean connected = false;
static boolean doScan = false;
static BLERemoteCharacteristic* pRemoteCharacteristic;
static BLEAdvertisedDevice* myDevice;
bool  BLE_dataReceived = false;
unsigned char Data_Buffer[FRAME_SIZE] = { 0 };

// BLE client callback class
class MyClientCallback : public BLEClientCallbacks 
{
  void onConnect(BLEClient* pclient) 
  {
    // Empty implementation since we don't need to perform any action on connect
     connected = true;
  }
  void onDisconnect(BLEClient* pclient) 
  {
    connected = false;
    Serial.println("onDisconnect");
  }
};
static void notifyCallback(BLERemoteCharacteristic* pBLERemoteCharacteristic, uint8_t* pData, size_t length, bool isNotify) 
{
    // Check if the received data contains at least the magic word and number of objects
    if (length < 3 || pData[0] != MAGIC_WORD) 
    {
        Serial.println("Invalid frame received");
        return;
    }

    // Extract data from the frame
    uint8_t numObjects = pData[1];
    Serial.print("Number of objects: ");
    Serial.println(numObjects);
    
    // Check if there's enough data for the specified number of objects
    if (length < 3 + numObjects * 3) 
    {
        Serial.println("Insufficient data received");
        return;
    }

    // Determine the maximum number of bytes to copy
    size_t bytesToCopy = min(numObjects * 3, FRAME_SIZE - 3);

    // Copy object data into Data_Buffer
    memcpy(Data_Buffer + 3, pData + 2, bytesToCopy);

    // Set flag indicating new data received
    BLE_dataReceive = true;
}
bool connectToServer() 
{
    Serial.print("Forming a connection to ");
    Serial.println(myDevice->getAddress().toString().c_str());
    
    BLEClient* pClient = BLEDevice::createClient();
    Serial.println(" - Created client");

    pClient->setClientCallbacks(new MyClientCallback());

    // Connect to the remove BLE Server.
    pClient->connect(myDevice);
    Serial.println(" - Connected to server");
  
    // Obtain a reference to the service we are after in the remote BLE server.
    BLERemoteService* pRemoteService = pClient->getService(serviceUUID);
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

    // Register for notifications
    if (pRemoteCharacteristic->canNotify())
      pRemoteCharacteristic->registerForNotify(notifyCallback);

    return true;
}
void setup() 
{
    Serial.begin(9600);
    gpsSerial.begin(9600); /* Initialize GPS serial communication */
    /* Set pin modes for all pins used */
    /******************************* Set pin modes for 7segments & shiftRegister **************************************/ 
    pinMode(LATCHPIN, OUTPUT);
    pinMode(CLOCKPIN, OUTPUT);
    pinMode(DATAPIN, OUTPUT);
    pinMode(COMMON1PIN, OUTPUT);
    pinMode(COMMON2PIN, OUTPUT);
    /******************************* Set pin modes for LEDs & Switch **************************************/
    pinMode(LED_PIN, OUTPUT);
    pinMode(BUTTON_PIN, INPUT_PULLUP); // Set the button pin as input with internal pull-up resistor
    pinMode(BUZZER_PIN, OUTPUT); // Set the buzzer pin as output
    pinMode(LED_1, OUTPUT);
    pinMode(LED_2, OUTPUT);
    pinMode(LED_3, OUTPUT);
    pinMode(LED_4, OUTPUT);
    pinMode(LED_5, OUTPUT);
    /******************************* Set pin modes for Battary & RGB **************************************/
    pinMode(RED_LED_PIN, OUTPUT);
    pinMode(GREEN_LED_PIN, OUTPUT);
    pinMode(BLUE_LED_PIN, OUTPUT);
    BLEDevice::init("ESP32 BLE Client");
    //Start connection 
    connectToServer();
    // Wait for connection
    while (!connected) 
    {
      digitalWrite(LED_PIN, HIGH); // Turn LED on
      delay(500); // Wait for 500 milliseconds
      digitalWrite(LED_PIN, LOW); // Turn LED off
      delay(500); // Wait for 500 milliseconds
    }
    // Once connected, set LED to LOW and connect to the server
    digitalWrite(LED_PIN, LOW);
}
void loop() 
{
  int Battery_Level = analogRead(BATTERY_INPUT_PIN);
  int Battery_Health = map(Battery_Level, 0, 4095, 0, 100); // Map the analog input value to percentage
  Serial.print("Battery Health: ");
  Serial.print(Battery_Health);
  Serial.println("%");
  if (Battery_Health >= 0 && Battery_Health <= 30) 
  {
    // Light Red
    analogWrite(RED_LED_PIN, 255);
    analogWrite(GREEN_LED_PIN, 0);
    analogWrite(BLUE_LED_PIN, 0);
  } 
  else if (Battery_Health >= 71 && Battery_Health <= 100) 
  {
    // Light Blue
    analogWrite(RED_LED_PIN, 0);
    analogWrite(GREEN_LED_PIN, 0);
    analogWrite(BLUE_LED_PIN, 255);
  }
  else
  {
    // Light Green
    analogWrite(RED_LED_PIN, 0);
    analogWrite(GREEN_LED_PIN, 255);
    analogWrite(BLUE_LED_PIN, 0);
  }
  while (gpsSerial.available() > 0) 
  {
    gps.encode(gpsSerial.read()); /* Feed GPS data to TinyGPS++ */
  }
  /* Check if new GPS data is available */ 
  if (gps.location.isUpdated()) 
  {
    /* Get latitude and longitude */ 
    Serial.print("Latitude: ");
    Serial.println(gps.location.lat(), 8);
    Serial.print("Longitude: ");
    Serial.println(gps.location.lng(), 8);
  }
  /* Check if speed data is available */
  if (gps.speed.isUpdated()) 
  { 
    /* Convert speed to kilometers per hour */
    float speed = gps.speed.kmph();
    Serial.print("Speed (km/h): ");
    Serial.println(speed);
    displayNumber(speed);
  }

  if(BLE_dataReceive) 
  {
    // Number of objects from received data
    uint8_t numObjects = Data_Buffer[1];
    // Process distance data for each object
    for (int i = 0; i < numObjects; i++) 
    {
      uint8_t distance = Data_Buffer[3 + i * 3];
      // Call the function to process distance
      processDistance(distance);
    }
    // Reset the flag once data is processed
    BLE_dataReceive = false;
  }
  //Switch & Buzzer 
  if(LED_1_On && LED_2_On)
  {
    bool currentButtonState = digitalRead(BUTTON_PIN); // Read the current state of the button
    if (currentButtonState == LOW && buttonState == HIGH) 
    { // Check if the button is pressed and was previously released
        delay(50); // Debounce delay
        if (digitalRead(BUTTON_PIN) == LOW) 
        { // Check again after debounce delay
        clickCount++; // Increment click count
        Serial.print("Click count: ");
        Serial.println(clickCount);

      // Control buzzer intensity based on click count using PWM
        if (clickCount <= 3) 
        {
          switch(clickCount) 
          {
            case 1 : Buzzer_Freq(BUZZER_PIN, BUZZER_LOW);  break;
            case 2 : Buzzer_Freq(BUZZER_PIN, BUZZER_MID);  break;
            case 3 : Buzzer_Freq(BUZZER_PIN, BUZZER_HIGH); break;        
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
    delay(200);
  }
  /* Wait a bit before reading GPS data again */
  delay(1000);
}
void processDistance(uint8_t distance) 
{
  // Reset all LED flags
  LED_1_On = false;
  LED_2_On = false;
  LED_3_On = false;
  LED_4_On = false;
  LED_5_On = false;
  // Check distance range and set corresponding LED flags
  if (distance >= 0 && distance <= 30) 
  {
    LED_1_On = true;
  } 
  else if (distance >= 31 && distance <= 60) 
  {
    LED_2_On = true;
  } 
  else if (distance >= 61 && distance <= 90) 
  {
    LED_3_On = true;
  } 
  else if (distance >= 91 && distance <= 120) 
  {
    LED_4_On = true;
  } 
  else if (distance >= 121 && distance <= 150)
  {
    LED_5_On = true;
  }
  // Update LED states
  digitalWrite(LED_1, LED_1_On ? HIGH : LOW);
  digitalWrite(LED_2, LED_2_On ? HIGH : LOW);
  digitalWrite(LED_3, LED_3_On ? HIGH : LOW);
  digitalWrite(LED_4, LED_4_On ? HIGH : LOW);
  digitalWrite(LED_5, LED_5_On ? HIGH : LOW);
}
void displayNumber(float number)
{

  int tens  = (int)number / 10;/* Extract tens digit  */
  int units = (int)number % 10;/* Extract units digit */

  /* Display tens digit on DIG1 */
  digitalWrite(COMMON1PIN, HIGH);
  digitalWrite(COMMON2PIN, LOW);
  digitalWrite(LATCHPIN, LOW);
  shiftOut(DATAPIN, CLOCKPIN, MSBFIRST, segments[tens]);
  digitalWrite(LATCHPIN, HIGH);
  delay(10);

  /* Display units digit on DIG2 */
  digitalWrite(COMMON1PIN, LOW);
  digitalWrite(COMMON2PIN, HIGH);
  digitalWrite(LATCHPIN, LOW);
  shiftOut(DATAPIN, CLOCKPIN, MSBFIRST, segments[units]);
  digitalWrite(LATCHPIN, HIGH);
  delay(10); 
}
void Buzzer_Freq (uint8_t Buzzer_Pin, uint8_t Freq) 
{
  analogWrite(Buzzer_Pin, Freq);
}