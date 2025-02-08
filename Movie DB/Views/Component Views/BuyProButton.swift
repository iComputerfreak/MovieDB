//
//  BuyProButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import os.log
import StoreKit
import SwiftUI

struct BuyProButton: View {
    @Environment(\.dismiss) private var dismiss

    private let storeManager: StoreManager = .shared

    var product: Product? {
        storeManager.products.first(where: \.id, equals: JFLiterals.inAppPurchaseIDPro)
    }
    
    var displayPrice: String {
        product?.displayPrice ?? "Error"
    }
    
    var buttonLabel: String {
        if storeManager.hasPurchasedPro {
            return Strings.ProInfo.buyButtonLabelDisabled
        } else {
            return Strings.ProInfo.buyButtonLabel(displayPrice)
        }
    }
    
    var body: some View {
        Button(buttonLabel) {
            Task(priority: .userInitiated) {
                do {
                    try await buyPro()
                } catch {
                    AlertHandler.showSimpleAlert(
                        title: Strings.ProInfo.Alert.buyProErrorMessage,
                        message: Strings.ProInfo.Alert.buyProErrorMessage
                    )
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(storeManager.hasPurchasedPro)
    }
    
    func buyPro() async throws {
        Logger.appStore.info("Buying Pro")
        guard let proProduct = storeManager.products.first(where: \.id, equals: JFLiterals.inAppPurchaseIDPro) else {
            throw PurchaseError.productNotFound
        }
        
        // Execute the purchase
        let result = try await storeManager.purchase(proProduct)
        
        // Dismiss on a successful purchase
        if result != nil {
            dismiss()
        }
    }
}

#Preview {
    BuyProButton()
        .previewEnvironment()
}
