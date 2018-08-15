//
//  TimeTableViewCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class TimeTableViewCellViewModel: MoreOptionsTableViewCellViewModelProtocol {
    
    func title() -> String {
        return Strings.MoreOptionsScreen.TimeCell.title
    }
    
    func subtitle() -> String {
        return Strings.MoreOptionsScreen.TimeCell.subtitle
    }
    
    func imageName() -> String {
        return "timeButton"
    }
    
}
