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
        return "Time"
    }
    
    func subtitle() -> String {
        return "Set a date for your task"
    }
    
    func imageName() -> String {
        return "timeButton"
    }
    
}
