var LOCATION_LEFT = "left";
var LOCATION_NONE = "none";
var LOCATION_RIGHT = "right";

var client;    

// Connected    
function doClientConnect( context ) {
    console.log( 'Connected.' );

	// Add handler for messages
	// Subscribe to topic
	client.onMessageArrived = doStageArrived;	
	client.subscribe( IOT_TOPIC );
}    
    
// Unable to connect
function doClientFailure( context, code, message ) {
    console.log( 'Connection fail.' );
}    
    
// Message arrived	
function doStageArrived( message ) {
	var data = null;
	var element = null;
	
	// Parse JSON-formatted data
	data = JSON.parse( message.payloadString );
	console.log( data );
		
	// Show or hide callouts based on data
    if( data.stage == LOCATION_LEFT ) {
        element = document.querySelector( '.callout.left' );
        element.style.visibility = 'visible';            
		
        element = document.querySelector( '.callout.right' );
        element.style.visibility = 'hidden';            		
    } else if( data.stage == LOCATION_RIGHT ) {
        element = document.querySelector( '.callout.right' );        
        element.style.visibility = 'visible';    
		
        element = document.querySelector( '.callout.left' );        
        element.style.visibility = 'hidden';    		
    } else if( data.stage == LOCATION_NONE ) {
        element = document.querySelectorAll( '.callout' );
        
        for( var c = 0; c < element.length; c++ ) {
            element[c].style.visibility = 'hidden';
        }
    }    
}	
	
// Main
function doWindowLoad() {
	// Instantiate Watson client (MQTT)
    try {
        client = new Paho.MQTT.Client(
            IOT_HOST, 
            IOT_PORT, 
            IOT_CLIENT + Math.round( Math.random() * 1000 )
        );
    } catch( error ) {
        console.log( 'Error: ' + error );
    }    
    
	// Connect to Watson
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
	var callouts = null;
	
	// Keep callouts sized to cover	
	callouts = document.querySelectorAll( '.callout' );
	
	for( var c = 0; c < callouts.length; c++ ) {
		callouts[c].style.width = Math.round( window.innerWidth / callouts.length ) + 'px';
	}
}

// Start and manage layout
window.addEventListener( 'load', doWindowLoad );    
window.addEventListener( 'resize', doWindowResize );    
