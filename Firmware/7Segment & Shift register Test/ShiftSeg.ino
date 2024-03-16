// Define pin assignments for the 7-segment display
#define  DATAPIN     D18  //Pin for data signal  IO18/pin30
#define  CLOCKPIN    D19  //Pin for clock signal IO19/pin31
#define  LATCHPIN    D21  //Pin for latch signal IO21/pin33
#define  COMMON1PIN  D15  //Pin for common Cathode 1 IO15/pin23
#define  COMMON2PIN  D14  //Pin for common Cathode 2 IO14/pin13

uint32_t Tick_Counter = 0;  // Variable to track time intervals

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

// Function prototype to display a number on the 7-segment display
void displayNumber(int number);

// Setup function, runs once when the microcontroller starts
void setup()
{
  // Set pin modes for all pins used
  pinMode(LATCHPIN, OUTPUT);
  pinMode(CLOCKPIN, OUTPUT);
  pinMode(DATAPIN, OUTPUT);
  pinMode(COMMON1PIN, OUTPUT);
  pinMode(COMMON2PIN, OUTPUT);

}

// Loop function, runs repeatedly after setup.
void loop()
{
  int i=0;
// Loop to display numbers from 0 to 99.
  while(i<100)
  {
    // Update display every second.
    if((millis()-Tick_Counter)>=1000)
    {
      displayNumber(i);
      i++;
      Tick_Counter = millis();
    }
    else
    {
      displayNumber(i-1);
    } 
  }

}
// Function to display a number on the 7-segment display.
void displayNumber(int number)
{
  int tens  = number / 10;
  int units = number % 10;
  // Display tens digit on common Cathode 1.
  digitalWrite(COMMON1PIN, HIGH);
  digitalWrite(COMMON2PIN, LOW);
  digitalWrite(LATCHPIN, LOW);
  shiftOut(DATAPIN, CLOCKPIN, MSBFIRST, segments[tens]);
  digitalWrite(LATCHPIN, HIGH);
  delay(10);
  // Display tens digit on common Cathode 2.
  digitalWrite(COMMON1PIN, LOW);
  digitalWrite(COMMON2PIN, HIGH);
  digitalWrite(LATCHPIN, LOW);
  shiftOut(DATAPIN, CLOCKPIN, MSBFIRST, segments[units]);
  digitalWrite(LATCHPIN, HIGH);
  delay(10); 
}