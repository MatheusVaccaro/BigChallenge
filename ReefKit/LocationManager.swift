//
//  LocationManager.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    
    let manager: CLLocationManager
    
    var currentLocation: CLLocationCoordinate2D? {
        return manager.location?.coordinate
    }
    
    init() {
        manager = CLLocationManager()
    }
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startMonitoring(region: CLCircularRegion) {
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
