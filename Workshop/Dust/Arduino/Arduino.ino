// Dust sensor
const int DUST_PIN = 7;

unsigned long duration;
unsigned long start_time;
unsigned long sample_time = 2000;
unsigned long lpo = 0;

float ratio = 0;
float concentration = 0;
 
void setup() {
  // Serial
  Serial.begin( 9600 );

  // Digital input
  pinMode( DUST_PIN, INPUT );

  // Non-blocking timer
  // Replacement for delay
  start_time = millis();
}
 
void loop() {
  // Read pin value
  duration = pulseIn( DUST_PIN, LOW );
  
  lpo = lpo + duration;

  // If timer has elapsed
  // Calculate and display
  if( ( millis() - start_time ) >= sample_time ) {
    // Calculate
    // http://www.seeedstudio.com/wiki/Grove_-_Dust_Sensor
    ratio = lpo / ( sample_time * 10.0 );
    concentration = 1.1 * pow( ratio, 3 ) - 3.8 * pow( ratio, 2 ) + 520 * ratio + 0.62;

    // Display
    Serial.println( concentration );

    // Reset clock and sample
    lpo = 0;
    start_time = millis();
  }
}

