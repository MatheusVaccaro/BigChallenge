//
//  LocationManager.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    let manager: CLLocationManager
    
    override init() {
        manager = CLLocationManager()
        super.init()
        
        manager.requestAlwaysAuthorization()
        
        manager.delegate = self
    }
    
    func startMonitoring(region: CLCircularRegion) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            //error: monitoring not available on device
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            //error: location not authorized by use
        }
        
        manager.startMonitoring(for: region)
    }
    
    func stopMonitoring(region: CLCircularRegion) {
        for region in manager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == region.identifier else { continue }
            manager.stopMonitoring(for: circularRegion)
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            // notify entered region
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            // notify exit region
        }
    }
}
