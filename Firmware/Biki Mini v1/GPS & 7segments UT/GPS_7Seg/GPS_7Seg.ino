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

void setup() {
  Serial.begin(115200);   // Initialize serial communication for debugging
  gpsSerial.begin(9600);  // Initialize GPS serial communication
  pinMode(DATAPIN, OUTPUT);
  pinMode(LATCHPIN, OUTPUT);
  pinMode(CLOCKPIN, OUTPUT);
  pinMode(COMMON1PIN, OUTPUT);
  pinMode(COMMON2PIN, OUTPUT);
}

void loop() {
  while (gpsSerial.available() > 0) {
    // if (millis() - startTime > timeout)
    //   break;
    gps.encode(gpsSerial.read());
  }
  if (gps.location.isUpdated()) {
    // Print latitude, longitude, and speed
    Serial.print("Latitude: ");
    Serial.print(gps.location.lat(), 8);
    Serial.print(", Longitude: ");
    Serial.print(gps.location.lng(), 8);
  }                              // Check for new GPS data
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

  delay(9);

  // Display units digit on common Anode 2.
  digitalWrite(COMMON1PIN, HIGH);
  digitalWrite(COMMON2PIN, LOW);

  for (int i = 7; i >= 0; i--) {
    digitalWrite(DATAPIN, !digits[units][i]);
    digitalWrite(CLOCKPIN, LOW);
    digitalWrite(CLOCKPIN, HIGH);
  }
  // digitalWrite(LATCHPIN, HIGH);
  delay(9);
}
