//
//  ThemeSelectionViewModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 08/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import StoreKit

class ThemeSelectionViewModel {
    var themes: [(product: SKProduct, theme: Theme)]
    
    let store: ReefStore
    
    init() {
        self.themes = []
        self.store = ReefStore(productIds: Set())
        
        store.requestProducts { (success, products) in
            if success {
                let products = products!
            }
        }
    }
}
