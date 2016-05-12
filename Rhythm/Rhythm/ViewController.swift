//
//  ViewController.swift
//  Rhythm
//
//  Created by Kevin Hoyt on 5/12/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import CocoaMQTT

import CoreBluetooth
import UIKit

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var labelHeart: UILabel!
    
    var mqtt:CocoaMQTT?
    
    var credentials:NSDictionary!
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    let CREDENTIALS_PATH = NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist")
    let RHYTHM_ARM_BAND = "RHYTHM+"
    let RYTHYM_HEART_UUID = CBUUID(string: "2A37")
    let RYTHYM_SERVICE_UUID = CBUUID(string: "180D")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // External credentials
        credentials = NSDictionary(contentsOfFile: CREDENTIALS_PATH!)
        
        labelHeart.hidden = true
        
        manager = CBCentralManager(delegate: self, queue: nil)
        
        mqtt = CocoaMQTT(
            clientId: (credentials.valueForKey("IoT Client") as? String)!,
            host: (credentials.valueForKey("IoT Host") as? String)!,
            port: UInt16((credentials["IoT Port"]?.intValue)!)
        )
        mqtt?.username = (credentials.valueForKey("IoT User") as? String)!
        mqtt?.password = (credentials.valueForKey("IoT Password") as? String)!
        mqtt?.delegate = self
        mqtt?.connect()
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
            
            let parameters = [
                "bpm": NSNumber(unsignedShort: count),
            ]
            
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
                let json = NSString(data: data, encoding: NSUTF8StringEncoding)
                let message = CocoaMQTTMessage(
                    topic: (credentials.valueForKey("IoT Topic") as? String)!,
                    string: json! as String
                )
                
                mqtt?.publish(message)
            } catch let error as NSError {
                debugPrint(error)
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        debugPrint("Disconnected.")
        
        central.scanForPeripheralsWithServices(nil, options: nil)
        
        labelHeart.hidden = true;
    }
    
}

extension ViewController: CocoaMQTTDelegate {
    
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("Connected.")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Connect acknowledge.")
        
        /*
         if ack == .ACCEPT {
         mqtt.subscribe(Constants.IOT_TOPIC)
         mqtt.ping()
         }
         */
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Publish: \(message.string!)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("Publish acknowledge.")
    }
    
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        /*
         if let data = message.string!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
         let json = JSON(data: data)
         print("Count: \(json["count"])")
         }
         */
    }
    
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("Subscribed.")
    }
    
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    func mqttDidPing(mqtt: CocoaMQTT) {
        print("Ping.")
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        print("Pong.")
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        print("Disconnect.")
    }
    
}

