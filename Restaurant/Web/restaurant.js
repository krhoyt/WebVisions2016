// Application
var client;    
var view;

// Ampersand click
// Alternate views
function doAndSelect() {
    var adventure = null;
    var destination = null;
    
    if( view == VIEW_BURGERS ) {
        view = VIEW_BEER;
        destination = 0 - window.innerWidth;
    } else if( view == VIEW_BEER ) {
        view = VIEW_BURGERS;
        destination = 0;
    }
    
    if( destination != null ) {
        adventure = document.querySelector( '.adventure' );        
        
        TweenMax.to( adventure, 1, {
            left: destination    
        } );
    }
}    
    
// Show bar orders screen
function doBeerSelect() {
    var adventure = null;
    
    // State
    view = VIEW_BEER;
    
    // Animate
    adventure = document.querySelector( '.adventure' );    
    TweenMax.to( adventure, 1, {
        left: 0 - window.innerWidth    
    } );
}        
    
// Show kitchen orders screen
function doBurgersSelect() {
    var adventure = null;
    
    // State
    view = VIEW_BURGERS;
    
    // Animate
    adventure = document.querySelector( '.adventure' );    
    TweenMax.to( adventure, 1, {
        left: 0    
    } );
}    
    
// Connected to IBM IoT Platform
function doClientConnect( context ) {
    console.log( 'Connect.' );
    client.subscribe( TOPIC_IOS );    
    client.subscribe( TOPIC_PHOTON );        
}    
    
// Unable to connect to IBM IoT Platform
function doClientFailure( context, code, message ) {
    console.log( 'Fail.' );
}        
    
// Order arrived from device
function doOrderArrived( message ) {
    var bar = null;
    var data = null;
    var kitchen = null;
    var row = null;
    var template = null;
    
    // Parse data
    data = JSON.parse( message.payloadString );    
    console.log( data );
    
    // Get order row template
    template = document.querySelector( '.row.template' );
    
    // Clone and populate
    row = template.cloneNode( true );    
    row.children[0].innerHTML = 'Table ' + data.table;
    row.children[1].innerHTML = data.name;    
    row.children[2].innerHTML = '$' + data.price;
    row.classList.remove( 'template' );
    
    // Burger or beer
    // Append order to list
    if( data.item == ITEM_BEER ) {
        bar = document.querySelector( '.bar' );
        bar.appendChild( row );        
    } else if( data.item == ITEM_BURGER ) {
        kitchen = document.querySelector( '.kitchen' );
        kitchen.appendChild( row );        
    }
}
    
// Window loaded
// Initialize
function doWindowLoad() {
    var and = null;
    var beer = null;
    var burgers = null;
    
    // Burger adventure
    burgers = document.querySelector( '.burgers' );
    burgers.addEventListener( 'click', doBurgersSelect );
    
    // Beer adventure
    beer = document.querySelector( '.beer' );
    beer.addEventListener( 'click', doBeerSelect );
    
    // Toggle adventure
    and = document.querySelector( '.and' );
    and.addEventListener( 'click', doAndSelect );
    
    // MQTT client
    // Over WebSocket
    try {
        client = new Paho.MQTT.Client(
            IOT_HOST, 
            IOT_PORT, 
            IOT_CLIENT + Math.round( Math.random() * 1000 )
        );
        client.onMessageArrived = doOrderArrived;
    } catch( error ) {
        console.log( 'Error: ' + error );
    }    

    // Connect to IBM IoT Platform
    client.connect( {
        userName: IOT_USERNAME,
        password: IOT_PASSWORD,
        onSuccess: doClientConnect,
        onFailure: doClientFailure
    } );
    
    // Layout
    doWindowResize();
}
    
// Window resized
// Layout
function doWindowResize() {
    var adventure = null;
    var and = null;
    var bar = null;
    var beer = null;
    var burgers = null;
    var kitchen = null;
    var question = null;
    
    // Kitchen orders
    kitchen = document.querySelector( '.kitchen' );
    kitchen.style.width = Math.round( window.innerWidth / 2 ) + 'px';
    kitchen.style.height = window.innerHeight + 'px';
    
    // Landing window
    question = document.querySelector( '.question' );
    question.style.width = window.innerWidth + 'px';
    question.style.height = window.innerHeight + 'px';
    question.style.left = Math.round( window.innerWidth / 2 ) + 'px';
    
    // Burger side of landing window
    burgers = document.querySelector( '.burgers' );
    burgers.style.width = Math.round( window.innerWidth / 2 ) + 'px';
    burgers.style.height = window.innerHeight + 'px';
    
    // Beer side of landing window
    beer = document.querySelector( '.beer' );
    beer.style.width = Math.round( window.innerWidth / 2 ) + 'px';
    beer.style.height = window.innerHeight + 'px';
    
    // Centered ampersand
    and = document.querySelector( '.and' );
    and.style.top = Math.round( ( window.innerHeight - and.clientHeight ) / 2 ) + 'px';
    
    // Bar orders
    bar = document.querySelector( '.bar' );
    bar.style.width = Math.round( window.innerWidth / 2 ) + 'px';
    bar.style.height = window.innerHeight + 'px';    
    bar.style.left = ( window.innerWidth + Math.round( window.innerWidth / 2 ) ) + 'px';
    
    // Panel that holds all other panels
    // As large as two fill browser windows
    adventure = document.querySelector( '.adventure' );
    adventure.style.left = ( 0 - Math.round( window.innerWidth / 2 ) ) + 'px';
}
    
// Let us do this!
window.addEventListener( 'load', doWindowLoad );
window.addEventListener( 'resize', doWindowResize );
