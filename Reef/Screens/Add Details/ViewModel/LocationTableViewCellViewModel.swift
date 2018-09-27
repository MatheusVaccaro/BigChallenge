//
//  LocationTableViewCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension LocationInputViewModel: IconCellPresentable {
    var title: String {
        return Strings.LocationInputView.Cell.title
    }
    
    var subtitle: String {
        if hasLocation {
            return placeName
        } else {
            return Strings.LocationInputView.Cell.subtitle
        }
    }
    
    var imageName: String {
        return "locationIcon"
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var voiceOverHint: String {
        return Strings.LocationInputView.Cell.subtitle
    }
    
    var voiceOverValue: String? {
        if hasLocation {
            return subtitle
        } else {
            return nil
        }
    }
}
