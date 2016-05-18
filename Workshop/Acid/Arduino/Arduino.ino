#include <SoftwareSerial.h>

const int RX_PIN = 2;
const int TX_PIN = 3;

SoftwareSerial atlas( RX_PIN, TX_PIN );

boolean complete = false;
float ph;
String sensor = "";

void setup() {
  // Serial (USB)
  Serial.begin( 9600 );

  // Serial (sensor)
  atlas.begin( 9600 );

  // Set aside some memory
  sensor.reserve( 30 );
}

void loop() {
  char in_character;

  // Read data from the device
  if( atlas.available() > 0 ) {
    in_character = ( char )atlas.read();
    sensor += in_character;

    // Carriage return indicates end
    if( in_character == '\r' ) {
      complete = true;
    }
  }

  // Finished reading from device
  if( complete ) {
    // Display (USB)
    Serial.print( sensor );
    Serial.print( "," );

    // Convert character string to numeric value
    ph = sensor.toFloat();

    // Range
    if( ph >= 7.0 ) {
      Serial.println( "high" );
    }

    if( ph <= 6.999 ) {
      Serial.println( "low" );
    }

    // Reset input from device
    sensor = "";
    complete = false;
  }
}

