import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var labelStage: UILabel!
    
    let CREDENTIALS_PATH = NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist")
    let BRAND_IDENTIFIER = "com.ibm"
    let BRAND_UUID: String = "A495DE30-C5B1-4B44-B512-1370F02D74DE"
    
    var beaconRegion: CLBeaconRegion!
    var credentials:NSDictionary!
    var locationManager: CLLocationManager!
    var watson:WatsonIoT!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelStage.hidden = true
        
        credentials = NSDictionary(contentsOfFile: CREDENTIALS_PATH!)
        
        watson = WatsonIoT(
            withClientId: (credentials.valueForKey("IoT Client") as? String)!,
            host: (credentials.valueForKey("IoT Host") as? String)!,
            port: NSNumber(int: (credentials["IoT Port"]?.intValue)!)
        )
        watson.connect(
            (credentials.valueForKey("IoT User") as? String)!,
            password: (credentials.valueForKey("IoT Password") as? String)!
        )
        
        let uuid = NSUUID(UUIDString: BRAND_UUID)
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: BRAND_IDENTIFIER)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }

    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        var closest:CLBeacon!
        var parameters:NSDictionary!
        
        if beacons.count > 0 {
            for beacon:CLBeacon in beacons {
                if closest == nil {
                    closest = beacon
                } else {
                    if beacon.rssi < closest.rssi {
                        closest = beacon
                    }
                }
            }

            if closest.proximity == CLProximity.Near {
                if closest.minor == 10 {
                    parameters = [
                        "stage": "left"
                    ]
                    
                    labelStage.text = "Left"
                    
                    debugPrint("Left")
                } else if closest.minor == 20 {
                    parameters = [
                        "stage": "right"
                    ]
                    
                    labelStage.text = "Right"
                    
                    debugPrint("Right")
                }
                
                labelStage.hidden = false;
            }
        } else {
            parameters = [
                "stage": "none"
            ]
            
            labelStage.hidden = true
        }
        
        if parameters != nil {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
                let json = NSString(data: data, encoding: NSUTF8StringEncoding)
                
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
