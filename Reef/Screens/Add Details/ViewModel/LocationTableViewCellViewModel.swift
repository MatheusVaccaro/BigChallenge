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
    
    var rightImageName: String {
        if !hasLocation {
            return "rightArrow"
        } else {
            return "removeButton"
        }
    }
    
    func rightImageClickHandler() {
        location = nil
        isArriving = true
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
    
    private var hasLocation: Bool {
        return location != nil
    }
}

extension StaticIconCellPresentable {
    static func defaultLocationInputIconCellPresentable() -> StaticIconCellPresentable {
        let staticIconCellPresentable = StaticIconCellPresentable(title: Strings.LocationInputView.Cell.title,
                                                                  subtitle: Strings.LocationInputView.Cell.subtitle,
                                                                  imageName: "locationIcon",
                                                                  voiceOverHint: Strings.LocationInputView.Cell.subtitle,
                                                                  voiceOverValue: nil)
        return staticIconCellPresentable
    }
}
