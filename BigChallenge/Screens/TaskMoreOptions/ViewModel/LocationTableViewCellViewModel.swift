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
        return "Location"
    }
    
    func subtitle() -> String {
        return "Remember at a specific location"
    }
    
    func imageName() -> String {
        return "locationButton"
    }
    
}
