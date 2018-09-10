//
//  TimeTableViewCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension DateInputViewModel: OptionCellPresentable {
    var title: String {
        return Strings.MoreOptionsScreen.TimeCell.title
    }
    
    var subtitle: String {
        return Strings.MoreOptionsScreen.TimeCell.subtitle
    }
    
    var imageName: String {
        return "timeButton"
    }
}
