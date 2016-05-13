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
 
    // Connect
    func connect(username:String, password:String) {
        mqtt?.username = username
        mqtt?.password = password
        mqtt?.connect()
    }
    
    // Publish
    func publish(topic:String, message:String) {
        let message = CocoaMQTTMessage(
            topic: topic,
            string: message
        )
        
        mqtt?.publish(message)
    }
    
    // Informational messages
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("Connected.")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Connect acknowledge.")
    }
    
    // See the raw JSON
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Publish: \(message.string!)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("Publish acknowledge.")
    }
    
    // Shows keep-alive activity
    func mqttDidPing(mqtt: CocoaMQTT) {
        print("Ping.")
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        print("Pong.")
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        print("Disconnect.")
    }
    
    // Unused
    // No subscribing in this application
    // Publish only
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {}
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {}
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {}
    
}
