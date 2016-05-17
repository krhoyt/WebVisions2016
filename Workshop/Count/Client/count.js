var client;    
    
// Connected to broker
// Subscribe for count topic
function doClientConnect( context ) {
    console.log( 'Connected.' );
	client.subscribe( IOT_TOPIC );
}    
    
// Unable to connect
function doClientFailure( context, code, message ) {
    console.log( 'Connection fail.' );
}    
    
// Message arrived
function doCountArrived( message ) {
	var data = null;
	var element = null;
	
	// Parse
	data = JSON.parse( message.payloadString );
	console.log( data );
	
	// Place on screen
	element = document.querySelector( '.count' );
	element.innerHTML = data.count;
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
		client.onMessageArrived = doCountArrived;
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
	
	// Layout
	doWindowResize();
}    
    
// Layout
function doWindowResize() {
	var element = null;
	
	// Center counter in screen
	element = document.querySelector( '.count' );
	element.style.top = Math.round( ( window.innerHeight - element.clientHeight ) / 2 ) + 'px';
}	
	
// Go
window.addEventListener( 'load', doWindowLoad );    
window.addEventListener( 'resize', doWindowResize );    
