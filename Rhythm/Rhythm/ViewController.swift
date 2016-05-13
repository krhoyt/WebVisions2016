import CocoaMQTT
import CoreBluetooth
import UIKit

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    // Only label on UI
    @IBOutlet weak var labelHeart: UILabel!
    
    let CREDENTIALS_PATH = NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist")
    let RHYTHM_ARM_BAND = "RHYTHM+"
    let RYTHYM_HEART_UUID = CBUUID(string: "2A37")
    let RYTHYM_SERVICE_UUID = CBUUID(string: "180D")
    
    var credentials:NSDictionary!
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    var watson:WatsonIoT!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        labelHeart.hidden = true
        
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
        
        // BLE
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    // Bluetooth is on
    // Start scanning
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            central.scanForPeripheralsWithServices(nil, options: nil)
            debugPrint("Searching ...")
        } else {
            debugPrint("Bluetooth not available.")
        }
    }

    // Found device during scan
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        // Rhythm heart rate monitor
        if device?.containsString(RHYTHM_ARM_BAND) == true {
            debugPrint("Found Rythym.")
            
            
            // Found
            // Stop scan
            self.manager.stopScan()
            
            // Store reference to device
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            // Connect to device
            manager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    // Connected to device
    // Discover device services
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        debugPrint("Getting services ...")
        peripheral.discoverServices(nil)
    }
    
    // Services were found
    // Get heart rate characteristics
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            debugPrint("Service: ", service.UUID.UUIDString)
            
            // Heart rate by UUID
            if service.UUID == RYTHYM_SERVICE_UUID {
                debugPrint("Using Heart Rate.")
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    // Characteristics retrieved
    // Set to notify of changes
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        debugPrint("Enabling ...")
        
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            debugPrint("Characteristic: ", thisCharacteristic.UUID.UUIDString)
     
            // Scratch
            if thisCharacteristic.UUID == RYTHYM_HEART_UUID {
                debugPrint("Set to notify: ", thisCharacteristic.UUID.UUIDString)
                
                // Show label (initially blank)
                labelHeart.hidden = false
                labelHeart.text = ""
                
                // Receive notification of changes
                self.peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
    }
    
    // Notification of value change
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // Check for heart rate change
        if characteristic.UUID == RYTHYM_HEART_UUID {
            var count:UInt16 = 0;
            
            // Calculate heart rate value
            // NSData to long
            // Divide by 256 per specification for this characteristic
            characteristic.value!.getBytes(&count, length: sizeof(UInt16))
            count = count / 256
            
            // UI
            labelHeart.text = NSString(format: "%llu", count) as String
            
            // Send to Watson
            // Assemble dictionary of parameters
            let parameters = [
                "bpm": NSNumber(unsignedShort: count),
            ]

            do {
                // Assemble JSON
                let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
                let json = NSString(data: data, encoding: NSUTF8StringEncoding)

                // Publish
                watson.publish(
                    (credentials.valueForKey("IoT Topic") as? String)!,
                    message: json! as String
                )
            } catch let error as NSError {
                debugPrint(error)
            }
        }
    }
    
    // Disconnected from the device
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        debugPrint("Disconnected.")
        
        // UI
        labelHeart.hidden = true;
        
        // Scan again
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
}
