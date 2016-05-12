long count = 0;

void setup() {
  // Only count while connected
  Bean.enableWakeOnConnect( true );  
}

void loop() {
  // Check for connection
  bool connected = Bean.getConnectionState();

  if( connected ) {
    // Increment counter
    count = count + 1;

    // Set to scratch data
    // Sleep for one second
    Bean.setScratchNumber( 1, count );    
    Bean.sleep( 1000 );
  } else {
    // Not connected
    // Deep sleep until connected
    // Technically wake at 49 days to check
    Bean.sleep( 0xFFFFFFFF );
  }
}

