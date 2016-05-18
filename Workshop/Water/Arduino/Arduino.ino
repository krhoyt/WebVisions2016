#include <OneWire.h> 

// Temperature sensor pin
const int DS18S20 = 7;

// Sensor
OneWire ds( DS18S20 );

// Setup serial
void setup( void ) {
  Serial.begin( 9600 );
}

// Infinite
void loop( void ) {
  // Get calculated temperature
  // Convert celcius to fahrenheit
  float celcius = getTemp();
  float fahrenheit = ( celcius * 1.8 ) + 32;

  // Send results over serial (USB)
  Serial.print( celcius );
  Serial.print( "," );
  Serial.println( fahrenheit );

  // Wait a second
  delay( 1000 );  
}

// Returns temperature celcius
// http://bildr.org/2011/07/ds18b20-arduino/
float getTemp() {
  byte data[12];
  byte addr[8];

  if( !ds.search( addr ) ) {
    ds.reset_search();
    return -1000;
  }

  if( OneWire::crc8( addr, 7 ) != addr[7] ) {
    Serial.println( "CRC is not valid." );
    return -1000;
  }

  if( addr[0] != 0x10 && addr[0] != 0x28 ) {
    Serial.print( "Device not recognized." );
    return -1000;
  }

  ds.reset();
  ds.select( addr );
  ds.write( 0x44, 1 );

  byte present = ds.reset();
  ds.select( addr );    
  ds.write( 0xBE );

  for( int i = 0; i < 9; i++ ) {
    data[i] = ds.read();
  }
  
  ds.reset_search();
  
  byte MSB = data[1];
  byte LSB = data[0];

  float tempRead = ( ( MSB << 8 ) | LSB );
  float TemperatureSum = tempRead / 16;
  
  return TemperatureSum;  
}

