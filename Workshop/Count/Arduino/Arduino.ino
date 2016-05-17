// Counter
long count = 0;

// Open serial (USB)
void setup() {
  Serial.begin( 9600 );
}

// Infinite
void loop() {
  // Increment
  count = count + 1;

  // Send to serial (USB)
  Serial.println( count );

  // Wait a second
  delay( 1000 );
}

