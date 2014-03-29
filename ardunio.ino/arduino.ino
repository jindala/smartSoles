#include <SPI.h>
#include <boards.h>
#include <services.h>
#include <ble_mini.h>

#define RED 4
#define GREEN 6
#define YELLOW 2
#define ANALOG_IN_PIN      A0

unsigned long currentMillis;        // store the current value from millis()
unsigned long previousMillis;       // for comparison with currentMillis
int samplingInterval = 100;          // how often to run the main loop (in ms)

void setup(){
  BLEMini_begin(57600);
  Serial.begin(57600);
  pinMode(RED, OUTPUT);
  pinMode(YELLOW, OUTPUT);
  pinMode(GREEN, OUTPUT);

}

void loop() {
  static boolean analog_enabled = true;
  while(BLEMini_available()==3) {
    byte pinColor=BLEMini_read();
    byte pinState=BLEMini_read();
    if(pinColor != 0xA0){
      if (pinState==0x01) {
        digitalWrite(pinColor, HIGH);
      }
      else {
        digitalWrite(pinColor, LOW);
      }
    }
    else if (pinColor == 0xA0) {
      // Command is to enable analog in reading
      if (pinState == 0x01) {
        analog_enabled = true;
      }
      else {
        analog_enabled = false;
      }
    }

    if (analog_enabled) {
      // if analog reading enabled
      currentMillis = millis();
      if (currentMillis - previousMillis > samplingInterval) {
        previousMillis += millis();

        // Read and send out
        uint16_t value = analogRead(ANALOG_IN_PIN);
        BLEMini_write(0x0B);
        BLEMini_write(value >> 8);
        BLEMini_write(value);
      }
    }    
  }
}


