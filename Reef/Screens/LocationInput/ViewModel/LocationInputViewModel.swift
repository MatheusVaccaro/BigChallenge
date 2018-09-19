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
    func locationInput(_ locationInputViewModel: LocationInputViewModel, didFind location: CLCircularRegion, arriving: Bool)
}

class LocationInputViewModel {
    
    var task: Task? {
        didSet {
            location = task?.region
            isArriving = task?.isArriving ?? false
        }
    }
    
    var location: CLCircularRegion? {
        didSet {
            guard location != nil else { return }
            delegate?.locationInput(self, didFind: location!, arriving: isArriving)
        }
    }
    
    var isArriving: Bool = false {
        didSet {
            guard location != nil else { return }
            delegate?.locationInput(self, didFind: location!, arriving: isArriving)
        }
    }
    
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
