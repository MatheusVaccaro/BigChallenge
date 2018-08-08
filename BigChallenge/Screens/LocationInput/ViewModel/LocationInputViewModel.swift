//
//  LocationInputViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 02/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationInputDelegate: class {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool)
}

class LocationInputViewModel {
    
    public weak var delegate: LocationInputDelegate?
    
    var placeName = Strings.LocationInputView.defaultPlaceName
    let searchBarHint = Strings.LocationInputView.accessibilityHintSearchBar
    let mapViewAccessibilityLabel =
        Strings.LocationInputView.accessibilitylabelMap
    let mapViewAccessibilityValueEmpty =
        Strings.LocationInputView.accessibilityValueEmptyMap
    let arrivingString = Strings.LocationInputView.arrivingString
    let leavingString = Strings.LocationInputView.leavingString
    let searchBarPlaceholder = Strings.LocationInputView.searchBarPlaceholder
    
    func accessibilityValue(for radius: Int) -> String {
        let localizedString = Strings.LocationInputView.accessibilityValueMap
        return String.localizedStringWithFormat(localizedString,
                                         radius,
                                         placeName)
    }
    
}
