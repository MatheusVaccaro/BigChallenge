//
//  ThemeTableViewModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import StoreKit

protocol ThemeTableViewModelDelegate: class {
    func isProductPurchased(_ product: SKProduct) -> Bool
    func themeTableViewModelDelegate(_ themeTableViewModel: ThemeTableViewModel,
                                     shouldPromptProductPurchase product: SKProduct)
}

class ThemeTableViewModel {
    
    private(set) var theme: Theme.Type
    private(set) var product: SKProduct?
    
    weak var delegate: ThemeTableViewModelDelegate!
    
    var selectedImageName: String = "themeSelectedImage"
    
    var priceText: String {
        guard let product = product,
            !delegate.isProductPurchased(product) else { return "" }
        
        let formatter = NumberFormatter()
        formatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = product.priceLocale
        
        return formatter.string(from: product.price) ?? ""
    }
    
    var canSelect: Bool {
        guard let product = product else { return true }
        return delegate.isProductPurchased(product)
    }
    
    init(theme: Theme.Type, product: SKProduct?) {
        self.theme = theme
        self.product = product
    }
    
    func buy() {
        guard let product = product else { return }
        delegate.themeTableViewModelDelegate(self, shouldPromptProductPurchase: product)
    }
}
