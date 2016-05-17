var jsonfile = require( 'jsonfile' );
var mqtt = require( 'mqtt' );
var serialport = require( 'serialport' );
var SerialPort = serialport.SerialPort;

var config = jsonfile.readFileSync( 'config.json' );
var client;

// List ports
serialport.list( function( error, ports ) {
    ports.forEach( function( port ) {
        console.log( port.comName );
    } );
} );

// Connect to port
// Use newline parser
var arduino = new SerialPort( '/dev/cu.usbserial-DA01L7G3', {
  baudrate: 9600,
  parser: serialport.parsers.readline( '\n' )
} );

// Log when open
arduino.on( 'open', function () {
    console.log( 'Opened.' );
	
	// Connect to broker
	// Inform when connected
	client = mqtt.connect( config.host, {
		clientId: config.client + Math.round( Math.random() * 1000 ),
		password: config.password,
		port: config.port,
		username: config.user		
	} );
	client.on( 'connect', function() {
		console.log( 'Connected.' );
	} );
} );

// Log incoming data
arduino.on( 'data', function( data ) {
    console.log( 'Dust: ' + data );
	
	// Publish air quality to broker
	client.publish( config.topic, JSON.stringify( {
		dust: parseFloat( data )
	} ) );
} );
