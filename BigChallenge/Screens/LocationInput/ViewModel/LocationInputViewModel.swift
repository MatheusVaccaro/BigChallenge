//
//  LocationInputViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 02/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class LocationInputViewModel {
    
    var placeName = "desired location"
    let searchBarHint = Strings.LocationInputView.accessibilityHintSearchBar
    let mapViewAccessibilityLabel =
        Strings.LocationInputView.accessibilitylabelMap
    let mapViewAccessibilityValueEmpty =
        Strings.LocationInputView.accessibilityValueEmptyMap
    let arrivingString = Strings.LocationInputView.arrivingString
    let leavingString = Strings.LocationInputView.leavingString
    
    func accessibilityValue(for radius: Int) -> String {
        let localizedString = Strings.LocationInputView.accessibilityValueMap
        return String.localizedStringWithFormat(localizedString,
                                         radius,
                                         placeName)
    }
    
}