import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    // Connectivity parts
    @IBOutlet weak var labelMajor: UILabel!
    @IBOutlet weak var labelMinor: UILabel!
    @IBOutlet weak var labelRSSI: UILabel!
    @IBOutlet weak var labelUUID: UILabel!
    @IBOutlet weak var viewRange: UIView!
    
    // Brand UUID set on beacon by owner
    // Populated initially by vendor
    // Most allow owner to change values
    let BRAND_IDENTIFIER = "com.ibm"
    let BRAND_UUID: String = "A495DE30-C5B1-4B44-B512-1370F02D74DE"
    
    // Beacons are a Core Location functionality
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do not show connection details
        viewRange.hidden = true
        
        // Define a beacon region
        let uuid = NSUUID(UUIDString: BRAND_UUID)
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: BRAND_IDENTIFIER)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        // Fire up location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // Authentication is required
        // Can be when in use or always
        // Appropriate string needs to be set in configuration
        locationManager.requestWhenInUseAuthorization()
        
        // Start looking for beacons
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }

    // Beacon(s) found
    // Also if beacon(s) lost
    // This application only shows the first in the list
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        // Have found beacons
        if beacons.count > 0 {
            // Show connection information
            viewRange.hidden = false

            // Populate connection details
            labelUUID.text = beacons[0].proximityUUID.UUIDString
            labelMajor.text = beacons[0].major.stringValue
            labelMinor.text = beacons[0].minor.stringValue
            labelRSSI.text = String(beacons[0].rssi)
            
            // Change color to reflect range
            // Ranging does not show actual distance to beacon
            if beacons[0].proximity == CLProximity.Far {
                viewRange.backgroundColor = UIColor.redColor()
            } else if beacons[0].proximity == CLProximity.Near {
                viewRange.backgroundColor = UIColor.yellowColor()
            } else if beacons[0].proximity == CLProximity.Immediate {
                viewRange.backgroundColor = UIColor.greenColor()
            }
        } else {
            // Beacon gone away
            viewRange.hidden = true
        }
    }
    
}
