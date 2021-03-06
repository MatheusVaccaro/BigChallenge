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
    func didStartPurchasing(product productID: String)
    func didCompletePurchasing(product productID: String)
    func didFailPurchasing(product productID: String)
    func didRestorePurchasing(product productID: String)
    func didDeferPurchasing(product productID: String)
}

class ThemeSelectionViewModel {
    var data: [(product: SKProduct?, theme: Theme.Type)]
    
    weak var delegate: ThemeSelectionViewModelDelegate?
    let store: ReefStore
    
    init() {
        self.data = [(nil, Classic.self)]
        self.store = ReefStore(productIds: Set([Dark.identifier]))
        store.delegate = self
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
    
    func viewModelForCell(at indexPath: IndexPath) -> ThemeTableViewModel {
        let item = data[indexPath.row]
        let viewModel = ThemeTableViewModel(theme: item.theme, product: item.product)
        viewModel.delegate = self
        return viewModel
    }
}

extension ThemeSelectionViewModel: ThemeTableViewModelDelegate {
    func isProductPurchased(_ product: SKProduct) -> Bool {
        return store.isProductPurchased(product.productIdentifier)
    }
    
    func themeTableViewModelDelegate(_ themeTableViewModel: ThemeTableViewModel, shouldPromptProductPurchase product: SKProduct) {
        store.buyProduct(product)
    }
}

extension ThemeSelectionViewModel: StoreKitTransactionDelegate {
    func didStartPurchasing(product productID: String) {
        delegate?.didStartPurchasing(product: productID)
    }
    
    func didCompletePurchasing(product productID: String) {
        delegate?.didCompletePurchasing(product: productID)
    }
    
    func didFailPurchasing(product productID: String) {
        delegate?.didFailPurchasing(product: productID)
    }
    
    func didRestorePurchasing(product productID: String) {
        delegate?.didRestorePurchasing(product: productID)
    }
    
    func didDeferPurchasing(product productID: String) {
        delegate?.didDeferPurchasing(product: productID)
    }
}
