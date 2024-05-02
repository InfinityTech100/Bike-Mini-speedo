#include <Arduino.h>

// Define pin assignments for the shift register and common anodes
#define DATAPIN     14  // Pin for data signal (IO18/pin30)
#define CLOCKPIN    13  // Pin for clock signal (IO19/pin31)
#define LATCHPIN    12  // Pin for latch signal (IO21/pin33)
#define COMMON1PIN  27  // Pin for common Anode 1 (IO15/pin23)
#define COMMON2PIN  26  // Pin for common Anode 2 (IO14/pin13)

uint32_t Tick_Counter = 0;  // Variable to track time intervals

// Binary representation of each digit from 0 to 9 for the 7-segment display
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


// Function prototype to display a number on the 7-segment display
void displayNumber(int number);

// Setup function, runs once when the microcontroller starts
void setup()
{
  // Set pin modes for all pins used
  Serial.begin(115200);
  pinMode(LATCHPIN, OUTPUT);
  pinMode(CLOCKPIN, OUTPUT);
  pinMode(DATAPIN, OUTPUT);
  pinMode(COMMON1PIN, OUTPUT);
  pinMode(COMMON2PIN, OUTPUT);
}

// Loop function, runs repeatedly after setup.
void loop()
{
  int i = 0;
  // Loop to display numbers from 0 to 99.
  while (i < 100)
  {
    // Update display every second.
    if ((millis() - Tick_Counter) >= 1000)
    {
      displayNumber(i);
      i++;
      Tick_Counter = millis();
      Serial.print("Count : ");
      Serial.println(i);
    }
    else
    {
      displayNumber(i - 1);
    }
  }
}
void displayNumber(int number) {
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
  for (int i = 7; i >= 0; i--) {
    digitalWrite(DATAPIN, !digits[units][i]);
    digitalWrite(CLOCKPIN, LOW);
    digitalWrite(CLOCKPIN, HIGH);
  }
  // digitalWrite(LATCHPIN, HIGH);
  delay(8);
}
