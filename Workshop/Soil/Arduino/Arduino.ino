// Soil moisture
const int SOIL_PIN = A0;

// Serial reporting
void setup() {
  Serial.begin( 9600 );
}

// Infinite
void loop() {
  int value;

  // Read analog value of soil moisture
  value = analogRead( SOIL_PIN );
  Serial.println( value );

  // Wait a second
  delay( 1000 );
}

