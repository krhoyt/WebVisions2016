var client;    
    
// Connected to broker
// Subscribe to muscle sensor topic
function doClientConnect( context ) {
    console.log( 'Connected.' );
	client.subscribe( IOT_TOPIC );
}    
    
// Unable to connect
function doClientFailure( context, code, message ) {
    console.log( 'Connection fail.' );
}    
    
// Message arrived
function doHulkArrived( message ) {
	var data = null;
	var element = null;
	
	// Parse
	data = JSON.parse( message.payloadString );
	console.log( data );
	
	// Reference to image display
	element = document.querySelector( '.myoware' );
	
	// Show image based on muscle voltage
	if( data.voltage > 1 ) {
		element.style.backgroundImage = 'url( hulk.jpg )';
	} else {
		element.style.backgroundImage = 'url( banner.jpg )';		
	}
}	
	
// Document loaded
function doWindowLoad() {
	// Instantiate client
    try {
        client = new Paho.MQTT.Client(
            IOT_HOST, 
            IOT_PORT, 
            IOT_CLIENT + Math.round( Math.random() * 1000 )
        );
		client.onMessageArrived = doHulkArrived;
    } catch( error ) {
        console.log( 'Error: ' + error );
    }    
    
	// Connect to broker
    client.connect( {
        userName: IOT_USER,
        password: IOT_PASSWORD,
        onSuccess: doClientConnect,
        onFailure: doClientFailure
    } );
}    
	
// Go
window.addEventListener( 'load', doWindowLoad );    
