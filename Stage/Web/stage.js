var LOCATION_LEFT = "left";
var LOCATION_NONE = "none";
var LOCATION_RIGHT = "right";

var client;    
    
function doClientConnect( context ) {
    console.log( 'Connected.' );
	client.subscribe( IOT_TOPIC );
}    
    
function doClientFailure( context, code, message ) {
    console.log( 'Connection fail.' );
}    
    
function doStageArrived( message ) {
	var data = null;
	var element = null;
	
	data = JSON.parse( message.payloadString );
	console.log( data );
	
    if( data.stage == LOCATION_LEFT ) {
        element = document.querySelector( '.circle.left' );
        element.style.visibility = 'visible';            
    } else if( data.stage == LOCATION_RIGHT ) {
        element = document.querySelector( '.circle.right' );        
        element.style.visibility = 'visible';    
    } else if( data.stage == LOCATION_NONE ) {
        element = document.querySelectorAll( '.circle' );
        
        for( var c = 0; c < element.length; c++ ) {
            element[c].style.visibility = 'hidden';
        }
    }
    
}	
	
function doWindowLoad() {
    try {
        client = new Paho.MQTT.Client(
            IOT_HOST, 
            IOT_PORT, 
            IOT_CLIENT + Math.round( Math.random() * 1000 )
        );
		client.onMessageArrived = doStageArrived;
    } catch( error ) {
        console.log( 'Error: ' + error );
    }    
    
    client.connect( {
        userName: IOT_USER,
        password: IOT_PASSWORD,
        onSuccess: doClientConnect,
        onFailure: doClientFailure
    } );
    
    doWindowResize();
}    
	
function doWindowResize() {
    var location = null;
    
    location = document.querySelector( '.location' );
    location.style.width = Math.round( window.innerWidth * 0.37 ) + 'px';
    location.style.bottom = Math.round( window.innerHeight * 0.17 ) + 'px';
    location.style.left = Math.round( ( window.innerWidth - location.clientWidth ) / 2 ) + 'px';
}

window.addEventListener( 'load', doWindowLoad );    
window.addEventListener( 'resize', doWindowResize );    
