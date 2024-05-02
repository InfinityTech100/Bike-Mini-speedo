#include <Arduino.h>
#include <BLEDevice.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>

#define BUTTON_PIN 32  // Define the pin for the button
#define BUZZER_PIN 33  // Define the pin for the buzzer
#define BUZZER_OFF 0
#define BUZZER_LOW 80
#define BUZZER_MID 140
#define BUZZER_HIGH 255

bool buttonState = HIGH;
uint8_t clickCount = 0;

void Buzzer_Freq(uint8_t Buzzer_Pin, uint8_t Freq);

void setup() {
  Serial.begin(115200);

  pinMode(BUTTON_PIN, INPUT_PULLUP);  // Set the button pin as input with internal pull-up resistor
  pinMode(BUZZER_PIN, OUTPUT);        // Set the buzzer pin as output
}

void loop() {
  handleButtonPress();
}

void handleButtonPress() {
  bool currentButtonState = digitalRead(BUTTON_PIN);
  
  if (currentButtonState == LOW && buttonState == HIGH) {
    delay(50);  // Debounce delay

    if (digitalRead(BUTTON_PIN) == LOW) {
      clickCount++;
      Serial.print("Click count: ");
      Serial.println(clickCount);

      if (clickCount <= 3) {
        switch (clickCount) {
          case 1: Buzzer_Freq(BUZZER_PIN, BUZZER_LOW); break;
          case 2: Buzzer_Freq(BUZZER_PIN, BUZZER_MID); break;
          case 3: Buzzer_Freq(BUZZER_PIN, BUZZER_HIGH); break;
          //case 4: Buzzer_Freq(BUZZER_PIN, BUZZER_OFF); break;
          default: Buzzer_Freq(BUZZER_PIN, 0); break;
        }
      } else {
        clickCount = 0;
      }
    }
  }
  
  buttonState = currentButtonState;
  delay(100);
}

void Buzzer_Freq(uint8_t Buzzer_Pin, uint8_t Freq) {
  analogWrite(Buzzer_Pin, Freq);
}
