import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // @IBOutlet weak var labelTable: UILabel!
    // @IBOutlet weak var viewTable: UIView!
    
    let BEACON_IDENTIFIER = "com.ibm"
    let BEACON_UUID = NSUUID(UUIDString: "A495DE30-C5B1-4B44-B512-1370F02D74DE")
    let CREDENTIALS_PATH = NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist")
    
    var region: CLBeaconRegion!
    var manager = CLLocationManager()
    var credentials:NSDictionary!
    var store: NSNumber!
    var table: NSNumber!
    var topic: String!
    var watson:WatsonIoT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        viewTable.layer.cornerRadius = 25.0
        viewTable.layer.borderColor = UIColor.whiteColor().CGColor
        viewTable.layer.borderWidth = 5.0
        viewTable.clipsToBounds = true
        viewTable.hidden = true
        */
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        region = CLBeaconRegion(proximityUUID: BEACON_UUID, identifier: BEACON_IDENTIFIER)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didBeerDown(sender: AnyObject) {
        let parameters = [
            "item": 900,
            "name": "Beer",
            "price": 1.23,
            "table": table.integerValue
        ]
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
            let json = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            watson.publish(topic, message: json! as String)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    @IBAction func didBurgerDown(sender: AnyObject) {
        let parameters = [
            "item": 800,
            "name": "Burger",
            "price": 12.34,
            "table": table.integerValue
        ]
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
            let json = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            watson.publish(topic, message: json! as String)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0 {
            for beacon in beacons {
                if beacon.proximity == CLProximity.Immediate {
                    if beacon.minor != table {
                        table = beacon.minor
                        
                        // labelTable.text = table.stringValue
                        // viewTable.hidden = false
                        
                        topic = "iot-2/evt/store\(beacon.major.integerValue)/fmt/json"
                        
                        debugPrint(topic)
                    }
                }
            }
        } else {
            // labelTable.text = ""
            // viewTable.hidden = true;
            table = 0;
        }
    }
    
}
