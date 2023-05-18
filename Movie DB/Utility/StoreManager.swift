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

// Modeled after https://developer.apple.com/documentation/storekit/in-app_purchase/implementing_a_store_in_your_app_using_the_storekit_api

public enum StoreError: Error {
    case failedVerification
}

class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProducts: [Product] = []
    
    /// Whether the user has purchased the pro version of the app
    var hasPurchasedPro: Bool {
        guard let proProduct = self.products.first(where: \.id, equals: JFLiterals.inAppPurchaseIDPro) else {
            return false
        }
        return self.isPurchased(proProduct)
    }
    
    // The task that is responsible for listening to background transactions
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        // Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()
        
        Task {
            // During store initialization, request products from the App Store.
            await requestProducts()
            
            // Update purchase statuses
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// Starts listening for transactions in the background
    /// - Returns: The background task performing the listening
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    Logger.appStore.error("Transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    /// Fetches all available products from App Store Connect and updates this `StoreManager`'s `products`
    func requestProducts() async {
        do {
            // TODO: We should store a list (maybe plist) of IDs somewhere else
            // Request products from the App Store.
            let storeProducts = try await Product.products(for: [JFLiterals.inAppPurchaseIDPro])
            
            self.products = storeProducts
        } catch {
            Logger.appStore.error("Failed product request from the App Store server: \(error, privacy: .public)")
        }
    }
    
    /// Purchases the given product
    /// - Parameter product: The `Product` to purchase
    /// - Returns: The transaction, or `nil`, if the purchase was cancelled or is pending.
    /// - Throws: `StoreError.failedVerification`, if the purchase could not be verified, or any errors that occur during the initial purchase process.
    func purchase(_ product: Product) async throws -> Transaction? {
        // Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            // Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    /// Returns the entitlement status of a given product
    /// - Parameter product: The product
    /// - Returns: Whether the user is entitled to this product (i.e. has purchased it)
    func isPurchased(_ product: Product) -> Bool {
        return purchasedProducts.contains(product)
    }
    
    /// Checks whether the given `VerificationResult` is valid
    /// - Parameter result: The result to check
    /// - Returns: The verified unwrapped result, or `nil` if the result could not be verified
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    @MainActor
    /// Updates the customer's purchase history
    func updateCustomerProductStatus() async {
        var purchasedProducts: [Product] = []

        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                if let product = products.first(where: \.id, equals: transaction.productID) {
                    purchasedProducts.append(product)
                }
            } catch {
                Logger.appStore.error("Error updating customer product status: \(error, privacy: .public)")
            }
        }
        
        // Update the store information with the purchased products.
        self.purchasedProducts = purchasedProducts
    }
    
    /// Manually requests to restore previously purchased products
    func restorePurchases() async throws {
        // This call displays a system prompt that asks users to authenticate with their App Store credentials.
        // Call this function only in response to an explicit user action, such as tapping a button.
        try? await AppStore.sync()
    }
}
