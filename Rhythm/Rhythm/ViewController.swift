//
//  ViewController.swift
//  Rhythm
//
//  Created by Kevin Hoyt on 5/12/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import CoreBluetooth
import UIKit

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var labelHeart: UILabel!
    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!

    let RHYTHM_ARM_BAND = "RHYTHM+"
    let RYTHYM_HEART_UUID = CBUUID(string: "2A37")
    let RYTHYM_SERVICE_UUID = CBUUID(string: "180D")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelHeart.hidden = true
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            central.scanForPeripheralsWithServices(nil, options: nil)
            debugPrint("Searching ...")
        } else {
            debugPrint("Bluetooth not available.")
        }
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if device?.containsString(RHYTHM_ARM_BAND) == true {
            debugPrint("Found Rythym.")
            
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        debugPrint("Getting services ...")
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            debugPrint("Service: ", service.UUID.UUIDString)
            
            // Heart rate
            if service.UUID == RYTHYM_SERVICE_UUID {
                debugPrint("Using Heart Rate.")
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
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
                
                // Get notification of changes
                self.peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // Heart rate
        if characteristic.UUID == RYTHYM_HEART_UUID {
            var count:UInt16 = 0;
            
            // NSData to long
            characteristic.value!.getBytes(&count, length: sizeof(UInt16))
            count = count / 256
            
            labelHeart.text = NSString(format: "%llu", count) as String
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        debugPrint("Disconnected.")
        
        central.scanForPeripheralsWithServices(nil, options: nil)
        
        labelHeart.hidden = true;
    }
}

