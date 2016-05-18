// Serial output (USB)
void setup() {
  Serial.begin( 9600 );
}

// Infinite
void loop() {
  float voltage;  
  int value;
  
  // Read analog signal
  value = analogRead( A0 );
  
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  // Convert analog to voltage level
  // 0 - 1023 == 0 - 5V
  voltage = value * ( 5.0 / 1023.0 );

  // Print values
  Serial.print( value );
  Serial.print( "," );
  Serial.println( voltage );

  // Slow down a little
  delay( 500 );
}

