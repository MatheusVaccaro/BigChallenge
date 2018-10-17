//
//  LocationInputViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 02/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import ReefKit

protocol LocationInputDelegate: class {
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion?,
                       named: String?,
                       arriving: Bool)
}

class LocationInputViewModel {
    
    var location: CLCircularRegion? {
        didSet {
            delegate?.locationInput(self, didFind: location, named: placeName, arriving: isArriving)
        }
    }
    
    var isArriving: Bool = true {
        didSet {
            delegate?.locationInput(self, didFind: location, named: placeName, arriving: isArriving)
        }
    }
    
    var tagInfo: [String] = []
    
    required init() { }
    
    public weak var delegate: LocationInputDelegate?
    
    var placeName: String? = nil
    let arrivingString = Strings.LocationInputView.arrivingString
    let leavingString = Strings.LocationInputView.leavingString
    let searchBarPlaceholder = Strings.LocationInputView.searchBarPlaceholder
    let searchBarHint = Strings.LocationInputView.VoiceOver.searchbarHint
    let mapViewAccessibilityLabel = Strings.LocationInputView.VoiceOver.mapLabel
}
