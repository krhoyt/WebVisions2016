// Libraries
#include "MQTT/MQTT.h"

// Debug mode
// #define SERIAL_DEBUG

// Physical button
const int BUTTON_PIN = D0;

// Suppress multiple publishes
// Button down will continue to read high while down
// Even the quickest human effort would result in multiple high reads
// Only want to order one burger so toggle release state
bool hold = false;

// Connectivity
char *IOT_CLIENT = "d:Organization:Device_Type:Device_ID";
char *IOT_HOST = "organization.messaging.internetofthings.ibmcloud.com";
char *IOT_PASSWORD = "_PASSWORD_";
char *IOT_PUBLISH = "iot-2/evt/store100/fmt/json";
char *IOT_USERNAME = "use-token-auth";

// MQTT for publish/subscribe to Watson IoT Platform
MQTT client( IOT_HOST, 1883, callback );

// Setup
void setup() {
    // Debug
    #ifdef SERIAL_DEBUG
        // Serial output
        Serial.begin( 9600 );

        // Hold until serial input
        while( !Serial.available() ) {
            Particle.process();
        }    
    #endif

    // Specify pin for button press
    pinMode( BUTTON_PIN, INPUT );
    
    // Connect to Watson IoT Platform
    client.connect( IOT_CLIENT, IOT_USERNAME, IOT_PASSWORD );

    // Subscribe
    // Unused for ordering
    if( client.isConnected() ) {
        // Debug
        #ifdef SERIAL_DEBUG
            Serial.println( "Connected." );
        #endif
        
        // Subscribe
        // client.subscribe( IOT_SUBSCRIBE );
    }
}

// Loop
void loop() {
    // Read pin (button) state
    // Will be high or low
    bool pressed = digitalRead( BUTTON_PIN );

    // Connect to Watson IoT Platform
    // Not worried about button otherwise
    if( client.isConnected() ) {
        // Pressed
        if( pressed && !hold ) {
            
            // Debug
            #ifdef SERIAL_DEBUG
                Serial.println( "Publish." );
            #endif
            
            // Track as pressed
            // Supress duplicates
            hold = true;
            
            // Publish order
            client.publish( 
                IOT_PUBLISH, 
                "{\"item\": 800, \"name\": \"Burger\", \"price\": 12.34, \"table\": 30}" 
            );            
        }
        
        // Button has been released
        if( !pressed && hold ) {
            // Debug
            #ifdef SERIAL_DEBUG
                Serial.println( "Released." );
            #endif
            
            // Track state as released
            hold = false;
        }

        // Process MQTT stream
        client.loop();
    }
}

// Reference for handing messages
void callback( char* topic, byte* payload, unsigned int length ) {
    char p[length + 1];
    
    memcpy( p, payload, length );
    p[length] = NULL;
    
    String message( p );

    // Debug
    #ifdef SERIAL_DEBUG    
        Serial.println( message );
    #endif
}
