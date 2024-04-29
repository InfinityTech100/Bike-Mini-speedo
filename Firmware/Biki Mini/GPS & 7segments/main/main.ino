#include <SoftwareSerial.h>
#include <TinyGPS++.h>

/* Define TX and RX pins for SoftwareSerial */ 
#define   GPS_RX_PIN   16   /* Pin for GPS RX signal IO16 */
#define   GPS_TX_PIN   17   /* Pin for GPS TX signal IO17 */

/* Define pin assignments for the 7-segment display and common Cathodes */ 
#define   CLOCKPIN    12   /* Pin for clock signal IO12 */ 
#define   LATCHPIN    13   /* Pin for latch signal IO13 */  
#define   DATAPIN     14   /* Pin for data  signal IO14 */ 

#define   COMMON1PIN  26   /* Pin for common cathode DIG1_EN IO26 */ 
#define   COMMON2PIN  27   /* Pin for common cathode DIG2_EN IO27 */

/* Create a TinyGPS++ object */ 
TinyGPSPlus gps;

/* Define SoftwareSerial object for GPS communication */
SoftwareSerial gpsSerial(GPS_RX_PIN, GPS_TX_PIN);
 
/* Function prototype to display a number on the 7-segment display */
void displayNumber(int number);

/* Binary representation of each digit from 0 to 9 for the 7-segment display */
const byte segments[] = 
{
  B00111111, /* 0 */
  B00000110, /* 1 */
  B01011011, /* 2 */
  B01001111, /* 3 */
  B01100110, /* 4 */
  B01101101, /* 5 */
  B01111101, /* 6 */
  B00000111, /* 7 */
  B01111111, /* 8 */
  B01101111  /* 9 */
};
void setup()
{
  Serial.begin(9600);    /* Initialize serial monitor */
  gpsSerial.begin(9600); /* Initialize GPS serial communication */
  /* Set pin modes for all pins used */ 
  pinMode(LATCHPIN, OUTPUT);
  pinMode(CLOCKPIN, OUTPUT);
  pinMode(DATAPIN, OUTPUT);
  pinMode(COMMON1PIN, OUTPUT);
  pinMode(COMMON2PIN, OUTPUT);

}

void loop()
{
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
  /* Wait a bit before reading GPS data again */
  delay(1000);
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

