var serialport = require( 'serialport' );
var SerialPort = serialport.SerialPort;

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
} );

// Log incoming data
arduino.on( 'data', function( data ) {
    console.log( 'Count: ' + data );
} );
