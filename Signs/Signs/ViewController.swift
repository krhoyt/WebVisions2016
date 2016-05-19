import Alamofire
import AVFoundation
import CoreLocation
import SwiftyJSON
import UIKit
import WatsonDeveloperCloud

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Click to translate copy
    @IBOutlet weak var buttonTranslate: UIButton!
 
    let CREDENTIALS_PATH = NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist")
    let BRAND_IDENTIFIER = "com.ibm"
    let BRAND_UUID: String = "A495DE30-C5B1-4B44-B512-1370F02D74DE"
    
    var beaconRegion: CLBeaconRegion!
    var credentials:NSDictionary!
    var lastMinor:NSNumber = 0
    var locationManager: CLLocationManager!
    
    var authentication:String!
    var authorization:NSData!
    var base64hash:String!
    var cloudant:NSURL!
    var language:LanguageTranslation!
    var player: AVAudioPlayer?
    var tts:TextToSpeech!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // No copy initially
        buttonTranslate.hidden = true
        
        // Cloudant credentials
        credentials = NSDictionary(contentsOfFile: CREDENTIALS_PATH!)
        authentication = "\((credentials.valueForKey("Cloudant User") as? String)!):\((credentials.valueForKey("Cloudant Password") as? String)!)"
        cloudant = NSURL(string: (credentials.valueForKey("Cloudant Find") as? String)!)
        
        authorization = authentication.dataUsingEncoding(NSUTF8StringEncoding)
        base64hash = authorization?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        // Watson translation
        language = LanguageTranslation(
            username: (credentials.valueForKey("Translate User") as? String)!,
            password: (credentials.valueForKey("Translate Password") as? String)!
        )
        
        // Watson text to speech (TTS)
        tts = TextToSpeech(
            username: (credentials.valueForKey("Speech User") as? String)!,
            password: (credentials.valueForKey("Speech Password") as? String)!
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
    
    @IBAction func didTranslateDown(sender: AnyObject) {
        translate((buttonTranslate.titleLabel?.text)!);
    }
        
    // Beacon(s) found or lost
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0 {                                      // There are beacons
            for beacon in beacons {                                 // Iterate
                if beacon.proximity == CLProximity.Immediate {      // Closest possible
                    if lastMinor != beacon.minor {                  // Not already loaded
                        debugPrint("Change to \(beacon.minor) (\(beacon.rssi)).")
                        lastMinor = beacon.minor                    // Store new beacon
                        lookup(beacon.major, minor: beacon.minor)   // Load details
                    }
                }
            }
        } else {
            // Hide copy
            buttonTranslate.hidden = true
        }
    }
    
    // Lookup copy for location from Cloudant (CouchDB)
    func lookup(major:NSNumber, minor:NSNumber) {
        let parameters = [
            "selector": [
                "major": major.integerValue,
                "minor": minor.integerValue,
                "demo": "signs"
            ],
            "fields": [
                "copy"
            ]
        ]
        let request = NSMutableURLRequest(URL: cloudant!)
        
        // Authentication
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic " + base64hash!, forHTTPHeaderField: "Authorization")
        
        // Formulate request
        try! request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: []);
        
        // Make request
        Alamofire.request(request)
            .responseJSON {
                response in
                
                // Got a result
                switch response.result {
                    case .Success:
                        // Parse JSON
                        // Get copy from result
                        let result = JSON(response.result.value!)
                        let copy = result["docs"][0]["copy"].stringValue

                        // Main thread
                        dispatch_async(dispatch_get_main_queue()) {
                            // Put copy on the screen
                            self.buttonTranslate.setTitle(copy, forState: UIControlState.Normal)
                            self.buttonTranslate.hidden = false;
                        }

                        debugPrint(result)
                    
                    // Bzzt!
                    case .Failure(let error):
                        debugPrint(error)
                }
        }
    }

    func speak(copy:String) {
        // Request audio of text from Watson
        tts.synthesize(copy, voice: "es-ES_EnriqueVoice") {
            data, error in
            
            // Play audio if possible
            if let audio = data {
                do {
                    self.player = try AVAudioPlayer(data: audio)
                    self.player!.play()
                } catch {
                    print("Could not play audio.")
                }
            } else {
                debugPrint(error)
            }
        }
    }
    
    func translate(copy:String) {
        // Tell Watson to translate the text for this location
        // Loaded from Cloudant based on beacon reporting
        language.translate(copy, source: "en", target: "es") {
            translation, error in
            
            // Main thread
            dispatch_async(dispatch_get_main_queue()) {
                // Update button label
                self.buttonTranslate.setTitle(translation!, forState: UIControlState.Normal)
                
                // Get spoken version
                self.speak(translation!)
            }
        
            debugPrint(translation)
        }
    }
    
}

