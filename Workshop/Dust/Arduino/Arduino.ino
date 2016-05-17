const int DUST_PIN = 7;

unsigned long duration;
unsigned long starttime;
unsigned long sampletime = 2000;
unsigned long lowpulseoccupancy = 0;

float ratio = 0;
float concentration = 0;
 
void setup() {
  Serial.begin( 9600 );
  pinMode( DUST_PIN, INPUT );
  starttime = millis();
}
 
void loop() {
  duration = pulseIn( DUST_PIN, LOW );
  lowpulseoccupancy = lowpulseoccupancy + duration;
 
  if( ( millis() - starttime ) >= sampletime ) {
    ratio = lowpulseoccupancy / ( sampletime * 10.0 );
    concentration = 1.1 * pow( ratio, 3 ) - 3.8 * pow( ratio, 2 ) + 520 * ratio + 0.62;
    Serial.println( concentration );
    lowpulseoccupancy = 0;
    starttime = millis();
  }
}

