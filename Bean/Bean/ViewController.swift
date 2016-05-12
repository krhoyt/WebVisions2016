//
//  ViewController.swift
//  Bean
//
//  Created by Kevin Hoyt on 5/5/16.
//  Copyright © 2016 IBM. All rights reserved.
//

// (1) Bluetooth
import CoreBluetooth
import UIKit

// (2) Delegates
class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var labelCount: UILabel!
    
    // (3) Manager, peripheral
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    // (4) UUID, name
    let BEAN_NAME = "Robu"
    let BEAN_SCRATCH_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let BEAN_SERVICE_UUID = CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide label until data
        labelCount.hidden = true;
        
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
        
        if device?.containsString(BEAN_NAME) == true {
            debugPrint("Found Bean.")
            
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
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
            
            // Scratch
            if service.UUID == BEAN_SERVICE_UUID {
                debugPrint("Using Scratch.")
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    // (10) List characteristics, setup notification
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        debugPrint("Enabling ...")
        
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            debugPrint("Characteristic: ", thisCharacteristic.UUID)
            
            // Scratch
            if thisCharacteristic.UUID == BEAN_SCRATCH_UUID {
                debugPrint("Set to notify: ", thisCharacteristic.UUID)
                
                // Show label (initially blank)
                labelCount.hidden = false
                labelCount.text = ""
                
                // Get notification of changes
                self.peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
    }
    
    // (11) Change notifications
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // Scratch
        if characteristic.UUID == BEAN_SCRATCH_UUID {
            var count:UInt32 = 0;
            
            // NSData to long
            characteristic.value!.getBytes(&count, length: sizeof(UInt32))
            
            labelCount.text = NSString(format: "%llu", count) as String
        }
    }
    
    // (12) Disconnect, try again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        debugPrint("Disconnected.")
        
        central.scanForPeripheralsWithServices(nil, options: nil)
        
        labelCount.hidden = true;
    }
    
}

