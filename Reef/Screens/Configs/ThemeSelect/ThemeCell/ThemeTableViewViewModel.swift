//
//  ThemeTableViewModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import StoreKit

class ThemeTableViewModel {
    
    private(set) var theme: Theme.Type
    
    private(set) var product: SKProduct?
    private var store: ReefStore
    
    var selectedImageName: String = "themeSelectedImage"
    
    var priceText: String {
        guard let product = product,
            !store.isProductPurchased(product.productIdentifier) else { return "" }
        
        let formatter = NumberFormatter()
        formatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = product.priceLocale
        
        return formatter.string(from: product.price) ?? ""
    }
    
    var canSelect: Bool {
        guard product != nil else { return true }
        return store.isProductPurchased(product!.productIdentifier)
    }
    
    init(theme: Theme.Type, product: SKProduct?, store: ReefStore) {
        self.theme = theme
        self.product = product
        self.store = store
    }
    
    func buy() {
        guard let product = product else { return }
        store.buyProduct(product)
    }
}
