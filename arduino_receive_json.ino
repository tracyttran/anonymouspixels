#include <Adafruit_NeoPixel.h>



#define LED_PIN 7
#define NUM_LEDS 49

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);
boolean readySent;

boolean firstUpdate = false;

//typedef struct color {
//  byte red;
//  byte green;
//  byte blue;
//} color;
//
//// row major array: row 1, row 2, etc...
//color color_arr[49];

byte red_arr[49];
byte green_arr[49];
byte blue_arr[49];


void setup() {
  Serial.begin(9600);
  readySent = false;
  strip.begin();
  for(uint16_t i=0; i<49; i++) {
      strip.setPixelColor(i  , strip.Color(255, 255, 255)); // Draw new pixel
  }
  strip.show();
  establishFirstContact();
  
}


void readCommand() {  
  
   String input = Serial.readString();
   char inputBuf[128];
   input.toCharArray(inputBuf, input.length() + 1); // for end of line character
    if (strncmp(inputBuf, "RCV", 3) == 0) {
        int expectedSize = atoi(inputBuf + 4);
        // Serial.println(expectedSize);
        byte fullMessage[expectedSize];
        byte firstPart[64];
        byte secondPart[64];
        byte thirdPart[19];
       
        if (expectedSize <= 0 || expectedSize > 1024) {
            return;
        }
        
        
       
        // ready for first 64 bytes
        Serial.println("RDY");

        while (Serial.available() <= 0) {
          delay(100);
        }
        
      Serial.readBytes(firstPart, 64); 

      for (int i = 0; i < 64; i++) {
          fullMessage[i] = firstPart[i]; 
        }
 

        Serial.println("ACK 1");

        while (Serial.available() <= 0) {
          delay(100);
          // wait for second batch of data
        }
        

        Serial.readBytes(secondPart, 64); 

  for (int i = 64; i < 128; i++) {
          fullMessage[i] = secondPart[i - 64]; 
        }

       

        Serial.println("ACK 2");

        
        while (Serial.available() <= 0) {
          delay(100);
          // wait for last batch of data
        }
//        

        Serial.readBytes(thirdPart, 19); 


        
        for (int i = 128; i < 147; i++) {
          fullMessage[i] = thirdPart[i - 128]; 
        }

        Serial.println("ACK 3");


        // update color array
        for (int i = 0; i < expectedSize; i = i + 3) {
          byte red = fullMessage[i];
          byte green = fullMessage[i + 1];
          byte blue = fullMessage[i + 2];
          red_arr[i / 3] = red;
          green_arr[i / 3] = green;
          blue_arr[i / 3] = blue;
        }
        updateColors();
        
    } 
}

void loop() {  
  if (Serial.available() > 0) {
      readCommand(); // start sequence
    } 
    delay(50);
}



void updateColors() {

  // row major order
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, strip.Color(red_arr[i], green_arr[i], blue_arr[i]));
    strip.show();
  }
  firstUpdate = true;
}

void establishFirstContact() {
//    for(uint16_t i=0; i<strip.numPixels(); i++) {
//      strip.setPixelColor(i  , strip.Color(0, 255, 0)); // Draw new pixel
//  }
//  strip.show();
  while (Serial.available() <= 0) {
    Serial.println("A");
    delay(300);
  }
//  for(uint16_t i=0; i<strip.numPixels(); i++) {
//      strip.setPixelColor(i  , strip.Color(255, 0, 0)); // Draw new pixel
//  }
//  strip.show();

}

void serialFlush(){
  while(Serial.available() > 0) {
    char t = Serial.read();
  }
}   




