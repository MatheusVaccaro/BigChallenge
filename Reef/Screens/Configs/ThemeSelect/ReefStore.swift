//
//  ReefIAPs.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 08/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import StoreKit

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

protocol StoreKitTransactionDelegate: class {
    func didStartPurchasing(product productID: String)
    func didCompletePurchasing(product productID: String)
    func didFailPurchasing(product productID: String)
    func didRestorePurchasing(product productID: String)
    func didDeferPurchasing(product productID: String)
}

open class ReefStore: NSObject {
    weak var delegate: StoreKitTransactionDelegate?
    
    private let productIdentifiers: Set<String>
    private var purchasedProductIdentifiers: Set<String> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    public init(productIds: Set<String>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = false //UserDefaults.standard.bool(forKey: productIdentifier) //TODO: save on coredata
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

// MARK: - StoreKit API
extension ReefStore {
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: String) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public static func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate
extension ReefStore: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for identifier in response.invalidProductIdentifiers {
            print("invalid product ids: \(identifier)")
        }
        
        for product in products {
            print("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver
extension ReefStore: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred:
                deferred(transaction: transaction)
            case .purchasing:
                purchasing(transaction: transaction)
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        SKPaymentQueue.default().finishTransaction(transaction)
        addPurchase(productID: transaction.payment.productIdentifier)
        delegate?.didCompletePurchasing(product: transaction.payment.productIdentifier)
    }
    
    func addPurchase(productID: String) {
        UserDefaults.standard.set(true, forKey: productID)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)
        addPurchase(productID: productIdentifier)
        delegate?.didRestorePurchasing(product: transaction.payment.productIdentifier)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        delegate?.didFailPurchasing(product: transaction.payment.productIdentifier)
    }
    
    private func deferred(transaction: SKPaymentTransaction) {
        print("deffered")
        delegate?.didDeferPurchasing(product: transaction.payment.productIdentifier)
    }
    
    private func purchasing(transaction: SKPaymentTransaction) {
        print("purchasing")
        delegate?.didStartPurchasing(product: transaction.payment.productIdentifier)
    }
}
