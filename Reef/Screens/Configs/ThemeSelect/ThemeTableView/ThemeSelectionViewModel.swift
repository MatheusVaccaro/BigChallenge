//
//  ThemeSelectionViewModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 08/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import StoreKit

protocol ThemeSelectionViewModelDelegate: class {
    func didLoadProducts()
}

class ThemeSelectionViewModel {
    var data: [(product: SKProduct?, theme: Theme.Type)]
    
    weak var delegate: ThemeSelectionViewModelDelegate?
    
    let store: ReefStore
    
    init() {
        self.data = [(nil, Classic.self)]
        self.store = ReefStore(productIds: Set([Dark.identifier]))
        //TODO (needs cloudkit): fetch product IDs
        
        store.requestProducts { (success, products) in
            if success {
                //TODO (needs cloudkit): fetch themes based on product identifier from cloudkit
                let themes: [Theme.Type] = [Classic.self, Dark.self]
                
                for product in products! {
                    if let theme = themes.first(where: { $0.identifier == product.productIdentifier }) {
                        self.data.append((product: product, theme: theme))
                    }
                }
                self.delegate?.didLoadProducts()
            }
        }
    }
}
