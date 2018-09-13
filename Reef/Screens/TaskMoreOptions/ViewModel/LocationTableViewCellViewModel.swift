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
        return Strings.MoreOptionsScreen.LocationCell.title
    }
    
    var subtitle: String {
        if location != nil {
            //TODO: Localize
            return (isArriving ? "arriving" : "leaving") + " \(placeName)"
        } else {
            return Strings.MoreOptionsScreen.LocationCell.subtitle
        }
    }
    
    var imageName: String {
        return "locationButton"
    }
}
