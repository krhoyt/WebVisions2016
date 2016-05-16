// Constants
var ITEM_BEER = 900;
var ITEM_BURGER = 800;
var UPDATE_RATE = 10000;
    
// Client
var interval = null;
var xhr = null;

// Call Cloudant for latest data
function update() {
    var hash = null;

    // Update dashboard a regular interval
    if( interval == null ) {
        interval = setInterval( update, UPDATE_RATE );
    }
    
    // Authentication
    hash = btoa( CLOUDANT_USERNAME + ':' + CLOUDANT_PASSWORD );    
    
    // Request
    xhr = new XMLHttpRequest();
    xhr.addEventListener( 'load', doOrdersLoad );
    xhr.open( 'GET', CLOUDANT_VIEW, true );
    xhr.setRequestHeader( 'Authorization', 'Basic ' + hash );
    xhr.send( null );    
}    
    
// Response from Cloudant
// Show order volume
function doOrdersLoad() {
    var beer = null;
    var burgers = null;
    var data = null;
    var element = null;
    
    // Parse incoming data
    data = JSON.parse( xhr.responseText );
    console.log( 'Rows: ' + data.rows.length );
    
    // Keep track
    bugers = 0;
    beer = 0;
    
    // Total orders
    for( var i = 0; i < data.rows.length; i++ ) {
        if( data.rows[i].value.item == ITEM_BURGER ) {
            burgers = burgers + 1;
        } else if( data.rows[i].value.item == ITEM_BEER ) {
            beer = beer + 1;
        }
    }
    
    // Populate burger count
    element = document.querySelector( '.burgers p:first-of-type' )
    element.innerHTML = burgers;
    
    // Populate beer count
    element = document.querySelector( '.beer p:first-of-type' )
    element.innerHTML = beer;    
    
    // Debug
    console.log( 'Burgers: ' + burgers + ', Beer: ' + beer );
    
    // Clean up
    xhr.removeEventListener( 'load', doOrdersLoad );
    xhr = null;
}    
    
// Page loaded
function doWindowLoad() {
    // Start updating
    update();
    
    // Layout
    doWindowResize();
}    
    
// Window resize
function doWindowResize() {
    var sum = null;
    
    // Position total
    sum = document.querySelector( '.sum' );
    sum.style.marginTop = Math.round( ( window.innerHeight - sum.clientHeight ) / 2 ) + 'px';
}    
    
// Get things going
window.addEventListener( 'load', doWindowLoad );
window.addEventListener( 'resize', doWindowResize );    
