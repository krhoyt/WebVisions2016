var client;    
    
function doClientConnect( context ) {
    console.log( 'Connected.' );
	client.subscribe( IOT_TOPIC );
}    
    
function doClientFailure( context, code, message ) {
    console.log( 'Connection fail.' );
}    
    
function doCountArrived( message ) {
	var data = null;
	var element = null;
	
	data = JSON.parse( message.payloadString );
	console.log( data );
	
	element = document.querySelector( '.count' );
	element.innerHTML = data.count;
}	
	
function doWindowLoad() {
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
    
    client.connect( {
        userName: IOT_USER,
        password: IOT_PASSWORD,
        onSuccess: doClientConnect,
        onFailure: doClientFailure
    } );
	
	doWindowResize();
}    
    
function doWindowResize() {
	var element = null;
	
	element = document.querySelector( '.count' );
	element.style.top = Math.round( ( window.innerHeight - element.clientHeight ) / 2 ) + 'px';
}	
	
window.addEventListener( 'load', doWindowLoad );    
window.addEventListener( 'resize', doWindowResize );    
