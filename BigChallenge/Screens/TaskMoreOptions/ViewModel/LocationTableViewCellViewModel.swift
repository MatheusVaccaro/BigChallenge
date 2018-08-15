//
//  LocationTableViewCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class LocationTableViewCellViewModel: MoreOptionsTableViewCellViewModelProtocol {
    
    func title() -> String {
        return Strings.MoreOptionsScreen.LocationCell.title
    }
    
    func subtitle() -> String {
        return Strings.MoreOptionsScreen.LocationCell.subtitle
    }
    
    func imageName() -> String {
        return "locationButton"
    }
    
}
