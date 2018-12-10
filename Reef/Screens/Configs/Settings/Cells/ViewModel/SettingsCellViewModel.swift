//
//  SettingsCellViewModel.swift
//  Reef
//
//  Created by Gabriel Paul on 08/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class SettingsCellViewModel {
    
    private(set) var type: SettingsCellType
    private(set) var title: String
    
    var cellIdentifier: String {
        return type == .toggleable ? "SettingsToggleableTableViewCell" : "SettingsTableViewCell"
    }
    
    let rightArrowImageName = "rightArrow"
    
    init(type: SettingsCellType, title: String) {
        self.type = type
        self.title = title
    }
}
