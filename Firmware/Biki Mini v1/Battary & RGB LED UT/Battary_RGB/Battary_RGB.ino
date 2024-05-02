#include <Arduino.h>
#include <BLEDevice.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>

#define   LED_R         22
#define   LED_G         21
#define   LED_B         23
#define   BATT_VOLTAGE  35
#define   CHG_STATUS    34
uint32_t Tick_counter2 = 0;
uint8_t prev_batt_percentage = 0;
int batt_val = 0;
uint8_t batt_percentage = 0;
bool firstTime =false;

void setup() 
{
  Serial.begin(115200);
  pinMode(BATT_VOLTAGE, INPUT_PULLDOWN);
  pinMode(LED_R, OUTPUT);
  pinMode(LED_G, OUTPUT);
  pinMode(LED_B, OUTPUT);
  digitalWrite(LED_R, LOW);
  digitalWrite(LED_G, LOW);
  digitalWrite(LED_B, LOW);
  pinMode(CHG_STATUS, INPUT);
}

void loop() 
{
  if ((millis() - Tick_counter2) >= 500) {
    // measure battery voltage and change RGB status according to battery level
    batt_lvl_check();
    Tick_counter2 = millis();
  }
}
void batt_lvl_check(void) {
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
    if (chg_stat == HIGH) {
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
    if (chg_stat == HIGH) {
      //toggle led for blinking if it's in charging mode
      digitalWrite(LED_B, !digitalRead(LED_B));
    } else {
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
