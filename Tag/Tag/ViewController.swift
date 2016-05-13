// (1) Bluetooth
import CoreBluetooth
import UIKit

// (2) Delegates
class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var labelHumidity: UILabel!
    @IBOutlet weak var labelObject: UILabel!
    
    // (3) Manager, peripheral
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    // (4) UUID
    // UUID specified by documentation
    let HUMIDITY_CONFIG_UUID = CBUUID(string: "F000AA22-0451-4000-B000-000000000000")
    let HUMIDITY_DATA_UUID = CBUUID(string: "F000AA21-0451-4000-B000-000000000000")
    let HUMIDITY_SERVICE_UUID = CBUUID(string: "F000AA20-0451-4000-B000-000000000000")
    let IR_CONFIG_UUID = CBUUID(string: "F000AA02-0451-4000-B000-000000000000")
    let IR_DATA_UUID = CBUUID(string: "F000AA01-0451-4000-B000-000000000000")
    let IR_SERVICE_UUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")
    let TAG_NAME = "SensorTag"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // (5) Manager
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    // (6) Scan
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            central.scanForPeripheralsWithServices(nil, options: nil)
            debugPrint("Searching ...")
        } else {
            debugPrint("Bluetooth not available.")
        }
    }
    
    // (7) Connect
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if device?.containsString(TAG_NAME) == true {
            debugPrint("Found SensorTag.")
            
            // Stop scanning
            self.manager.stopScan()
            
            // Store reference to device
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            // Connect
            manager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    // (8) Get services
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        debugPrint("Getting services ...")
        peripheral.discoverServices(nil)
    }
    
    // (9) List services, get characteristics
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            debugPrint("Service: ", service.UUID)
            
            // Humidity service
            if service.UUID == HUMIDITY_SERVICE_UUID {
                debugPrint("Using humidity.")
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            
            // IR service
            if service.UUID == IR_SERVICE_UUID {
                debugPrint("Using IR.")
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    // (10) List characteristics, setup notification
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        debugPrint("Enabling ...")
        
        var value = 1;
        let bytes = NSData(bytes: &value, length: sizeof(UInt8))
        
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            debugPrint("Characteristic: ", thisCharacteristic.UUID)
            
            // Humidity characteristic
            // Set to notify on change
            if thisCharacteristic.UUID == HUMIDITY_DATA_UUID {
                debugPrint("Set to notify: ", thisCharacteristic.UUID)
                self.peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            
            if thisCharacteristic.UUID == HUMIDITY_CONFIG_UUID {
                debugPrint("Configure: ", thisCharacteristic.UUID)
                self.peripheral.writeValue(bytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }
            
            // IR characteristic
            // Set to notify on change
            if thisCharacteristic.UUID == IR_DATA_UUID {
                debugPrint("Set to notify: ", thisCharacteristic.UUID)
                self.peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            
            if thisCharacteristic.UUID == IR_CONFIG_UUID {
                debugPrint("Configure: ", thisCharacteristic.UUID)
                self.peripheral.writeValue(bytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }
        }
    }
    
    // (11) Change notifications
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // Humidity characteristic
        if characteristic.UUID == HUMIDITY_DATA_UUID {
            let bytes = characteristic.value
            let length = bytes?.length
            var data = [UInt16](count: length!, repeatedValue: 0)
            
            bytes?.getBytes(&data, length: length! * sizeof(UInt16))
            
            // Calculations per documentation
            let humidity = (Double(data[1]) / 65536) * 100
            let temperature = (Double(data[0]) / 65536) * 165 - 40

            // Populate screen
            labelTemperature.text = NSString(format: "%.2f (C)", temperature) as String
            labelHumidity.text = NSString(format: "%.2f (%%)", humidity) as String
        }
        
        // IR characteristic
        if characteristic.UUID == IR_DATA_UUID {
            let bytes = characteristic.value
            let length = bytes?.length
            var data = [UInt16](count: length!, repeatedValue: 0)
            
            bytes?.getBytes(&data, length: length! * sizeof(UInt16))
            
            // Calculation per documentation
            let ambient = Double(data[0] >> 2) * 0.03125
            
            // Populate screen
            labelObject.text = NSString(format: "%.2f (C)", ambient) as String
        }
    }
    
    // (12) Disconnect, try again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        debugPrint("Disconnected.")
        central.scanForPeripheralsWithServices(nil, options: nil)
    }

}
