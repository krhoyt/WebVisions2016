//
//  WatsonIoT.swift
//  Rhythm
//
//  Created by Kevin Hoyt on 5/13/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import CocoaMQTT

import Foundation

class WatsonIoT:CocoaMQTTDelegate {
    
    var mqtt:CocoaMQTT?
 
    init(withClientId clientId:String, host:String, port:NSNumber) {
        mqtt = CocoaMQTT(
            clientId: clientId,
            host: host,
            port: UInt16(port.intValue)
        )
        mqtt?.delegate = self;
    }
    
    func connect(username:String, password:String) {
        mqtt?.username = username
        mqtt?.password = password
        mqtt?.connect()
    }
    
    func publish(topic:String, message:String) {
        let message = CocoaMQTTMessage(
            topic: topic,
            string: message
        )
        
        mqtt?.publish(message)
    }
    
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
