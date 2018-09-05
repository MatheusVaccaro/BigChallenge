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
    let arrivingString = Strings.LocationInputView.arrivingString
    let leavingString = Strings.LocationInputView.leavingString
    let searchBarPlaceholder = Strings.LocationInputView.searchBarPlaceholder

    let searchBarHint =
        Strings.LocationInputView.VoiceOver.searchbarHint
    let mapViewAccessibilityLabel =
        Strings.LocationInputView.VoiceOver.mapLabel
    
}
