//
//  ThemeTableViewModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class ThemeTableViewModel {
    
    private(set) var theme: Theme.Type
    
    init(theme: Theme.Type) {
        self.theme = theme
    }
}
