//
//  MKPlaceMarkExtension.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 08/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import MapKit

extension MKPlacemark {
    var fullAddress: String {
        let firstSpace =
            (subThoroughfare != nil && thoroughfare != nil) ? " - " : ""
        
        let comma = (subThoroughfare != nil || thoroughfare != nil) &&
            (subAdministrativeArea != nil || administrativeArea != nil) ? ", " : ""
        
        let secondSpace =
            (subAdministrativeArea != nil || administrativeArea != nil) ? " - " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            thoroughfare ?? "", comma, // street name,
            subThoroughfare ?? "", firstSpace, // street number -?
            locality ?? "", secondSpace, // city -?
            administrativeArea ?? "" // state
        )
        
        return addressLine
    }
}
