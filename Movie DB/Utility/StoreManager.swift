//
//  StoreManager.swift
//  Movie DB
//
//  Created by Jonas Frey on 20.06.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import os.log
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    
    @Published var products: [SKProduct] = []
    @Published var transactionState: SKPaymentTransactionState?
    
    private var purchaseCallback: () -> Void = {}
    
    func getProducts(productIDs: [String]) {
        Logger.appStore.info("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
    
    // MARK: - Fetch Products
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        Logger.appStore.info("Did receive response")
        
        DispatchQueue.main.async {
            if !response.products.isEmpty {
                self.products = []
                for fetchedProduct in response.products {
                    DispatchQueue.main.async {
                        self.products.append(fetchedProduct)
                    }
                }
            }
            
            for invalidIdentifier in response.invalidProductIdentifiers {
                Logger.appStore.warning("Invalid identifiers found: \(invalidIdentifier, privacy: .public)")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        Logger.appStore.error("Request did fail: \(error, privacy: .public)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.set(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .purchased
                AlertHandler.showSimpleAlert(
                    title: Strings.ProInfo.Alert.purchaseCompleteTitle,
                    message: Strings.ProInfo.Alert.purchaseCompleteMessage
                )
                // Inform the caller about a successful purchase
                purchaseCallback()
            case .restored:
                UserDefaults.standard.set(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .restored
                AlertHandler.showSimpleAlert(
                    title: Strings.ProInfo.Alert.purchaseRestoredTitle,
                    message: Strings.ProInfo.Alert.purchaseRestoredMessage
                )
            case .failed, .deferred:
                Logger.appStore.error("Payment Queue Error: \(transaction.error, privacy: .public)")
                queue.finishTransaction(transaction)
                transactionState = .failed
                AlertHandler.showSimpleAlert(
                    title: Strings.ProInfo.Alert.purchaseErrorTitle,
                    message: transaction.error?.localizedDescription
                )
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    /// Initiates a purchase of a product
    /// - Parameters:
    ///   - product: The product to purchase
    ///   - onSuccess: The closure to execute iff the product has been purchased successfully
    func purchase(product: SKProduct, onSuccess: @escaping () -> Void = {}) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            self.purchaseCallback = onSuccess
            SKPaymentQueue.default().add(payment)
        } else {
            Logger.appStore.warning("User can't make payment.")
            AlertHandler.showSimpleAlert(
                title: Strings.ProInfo.Alert.cannotMakePaymentsTitle,
                message: Strings.ProInfo.Alert.cannotMakePaymentsMessage
            )
        }
    }
}
