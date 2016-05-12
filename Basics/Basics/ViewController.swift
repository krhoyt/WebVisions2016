//
//  ViewController.swift
//  Basics
//
//  Created by Kevin Hoyt on 4/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var labelUUID: UILabel!
    @IBOutlet weak var labelMajor: UILabel!
    @IBOutlet weak var labelMinor: UILabel!
    @IBOutlet weak var labelRSSI: UILabel!
    @IBOutlet weak var viewRange: UIView!
    
    let BRAND_IDENTIFIER = "com.ibm"
    let BRAND_UUID: String = "A495DE30-C5B1-4B44-B512-1370F02D74DE"
    
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRange.hidden = true
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0 {
            viewRange.hidden = false
            
            labelUUID.text = beacons[0].proximityUUID.UUIDString
            labelMajor.text = beacons[0].major.stringValue
            labelMinor.text = beacons[0].minor.stringValue
            labelRSSI.text = String(beacons[0].rssi)
            
            if beacons[0].proximity == CLProximity.Far {
                viewRange.backgroundColor = UIColor.redColor()
            } else if beacons[0].proximity == CLProximity.Near {
                viewRange.backgroundColor = UIColor.yellowColor()
            } else if beacons[0].proximity == CLProximity.Immediate {
                viewRange.backgroundColor = UIColor.greenColor()
            }
        } else {
            viewRange.hidden = true
        }
    }
    
}
