import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Display table number on screen
    // Hide when no beacons
    @IBOutlet weak var labelTable: UILabel!
    @IBOutlet weak var viewTable: UIView!
    
    let BEACON_IDENTIFIER = "com.ibm"
    let BEACON_UUID = NSUUID(UUIDString: "A495DE30-C5B1-4B44-B512-1370F02D74DE")
    let CREDENTIALS_PATH = NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist")
    
    var region: CLBeaconRegion!
    var manager: CLLocationManager!
    var credentials:NSDictionary!
    var store: NSNumber!
    var table: NSNumber!
    var topic: String!
    var watson:WatsonIoT!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Stylize view holding the table number
        viewTable.layer.cornerRadius = 25.0
        viewTable.layer.borderColor = UIColor.whiteColor().CGColor
        viewTable.layer.borderWidth = 5.0
        viewTable.clipsToBounds = true
        viewTable.hidden = true
        
        // Change status bar to white
        // Shows on top of image
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Beacon region to monitor
        region = CLBeaconRegion(proximityUUID: BEACON_UUID!, identifier: BEACON_IDENTIFIER)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        // Location manager to watch for beacons
        manager = CLLocationManager();
        manager.delegate = self
        
        // Do not forget authorization in info
        manager.requestWhenInUseAuthorization()
        
        // Start monitoring for beacons
        manager.startMonitoringForRegion(region)
        manager.startRangingBeaconsInRegion(region)
        
        // External credentials
        credentials = NSDictionary(contentsOfFile: CREDENTIALS_PATH!)
        
        // Watson
        watson = WatsonIoT(
            withClientId: (credentials.valueForKey("IoT Client") as? String)!,
            host: (credentials.valueForKey("IoT Host") as? String)!,
            port: NSNumber(int: (credentials["IoT Port"]?.intValue)!)
        )
        watson.connect(
            (credentials.valueForKey("IoT User") as? String)!,
            password: (credentials.valueForKey("IoT Password") as? String)!
        )
    }
 
    // Beer buttong pressed
    // Send product details to Watson IoT
    // Real world details would be loaded from database
    @IBAction func didBeerDown(sender: AnyObject) {
        let parameters = [
            "item": 900,
            "name": "Beer",
            "price": 1.23,
            "table": table.integerValue
        ]
        
        do {
            // Serialize data into JSON formatted string
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
            let json = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            // Publish
            watson.publish(topic, message: json! as String)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    // Burgers button pressed
    // Send details to Watson IoT
    @IBAction func didBurgerDown(sender: AnyObject) {
        let parameters = [
            "item": 800,
            "name": "Burger",
            "price": 12.34,
            "table": table.integerValue
        ]
        
        do {
            // Serialize
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
            let json = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            // Publish
            watson.publish(topic, message: json! as String)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    // Found or lost beacons
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        // More than one is possible
        if beacons.count > 0 {
            // See which is closest
            for beacon in beacons {
                if beacon.proximity == CLProximity.Immediate {
                    // Watch for table (beacon) change
                    if beacon.minor != table {
                        // Store reference to table
                        // Passed to point of sale
                        table = beacon.minor
                        
                        // Display table number on screen
                        labelTable.text = table.stringValue
                        viewTable.hidden = false
                        
                        // Publish topic dependent on store number
                        // Store number from major beacon identifier
                        topic = "iot-2/evt/store\(beacon.major.integerValue)/fmt/json"
                        
                        debugPrint(topic)
                    }
                }
            }
        } else {
            // No beacons
            // Hide and clean up
            labelTable.text = ""
            viewTable.hidden = true
            
            table = 0
            topic = nil
        }
    }
    
}
