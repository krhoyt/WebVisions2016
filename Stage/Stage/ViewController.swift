import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    // Display side of stage on screen
    @IBOutlet weak var labelStage: UILabel!
    
    let CREDENTIALS_PATH = NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist")
    let BRAND_IDENTIFIER = "com.ibm"
    let BRAND_UUID: String = "DAEE8ED6-73C8-47C2-A2F2-5491E44E9A97"
    
    var beaconRegion: CLBeaconRegion!
    var credentials:NSDictionary!
    var locationManager: CLLocationManager!
    var watson:WatsonIoT!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // No position initially
        labelStage.hidden = true
        
        // Watson credentials
        credentials = NSDictionary(contentsOfFile: CREDENTIALS_PATH!)
        
        // Connect to Watson
        watson = WatsonIoT(
            withClientId: (credentials.valueForKey("IoT Client") as? String)!,
            host: (credentials.valueForKey("IoT Host") as? String)!,
            port: NSNumber(int: (credentials["IoT Port"]?.intValue)!)
        )
        watson.connect(
            (credentials.valueForKey("IoT User") as? String)!,
            password: (credentials.valueForKey("IoT Password") as? String)!
        )
        
        // Setup beacon region to monitor
        let uuid = NSUUID(UUIDString: BRAND_UUID)
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: BRAND_IDENTIFIER)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        // Beacons are part of Core Location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // Need permission from the user
        locationManager.requestWhenInUseAuthorization()
        
        // Start looking for beacons
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }

    // Beacon(s) found or lost
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        var closest:CLBeacon!
        var parameters:NSDictionary!
        
        // There are beacons
        if beacons.count > 0 {
            // Which one is the closest
            for beacon:CLBeacon in beacons {
                if closest == nil {
                    closest = beacon
                } else {
                    if beacon.rssi < closest.rssi {
                        closest = beacon
                    }
                }
            }

            // Map minor values to left or right
            if closest.minor == 100 {
                parameters = [
                    "stage": "left"
                ]
                    
                labelStage.text = "Left"
                    
                debugPrint("Left")
            } else if closest.minor == 200 {
                parameters = [
                    "stage": "right"
                ]
                    
                labelStage.text = "Right"
                    
                debugPrint("Right")
            }
            
            // Show the decision on screen
            labelStage.hidden = false;
        } else {
            // No beacons
            parameters = [
                "stage": "none"
            ]
            
            // Hide display
            labelStage.hidden = true
        }
        
        // If a beacon has been detected
        if parameters != nil {
            // Send details to Watson
            do {
                // Encode JSON-formatted string
                let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
                let json = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                // Publish details
                watson.publish(
                    (credentials.valueForKey("IoT Topic") as? String)!,
                    message: json! as String
                )
            } catch let error as NSError {
                debugPrint(error)
            }
        }
    }
    
}
