// Copyright © 2023 Jonas Frey. All rights reserved.

import os.log
import StoreKit
import SwiftUI
import Analytics

struct BuyProButton: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var isLoading: Bool

    private let storeManager: StoreManager = .shared

    init(isLoading: Binding<Bool> = .constant(false)) {
        self._isLoading = isLoading
    }

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
            isLoading = true
            Task(priority: .userInitiated) {
                defer {
                    Task { @MainActor in
                        isLoading = false
                    }
                }

                do {
                    try await buyPro()
                } catch {
                    AlertHandler.showSimpleAlert(
                        title: Strings.ProInfo.Alert.buyProErrorTitle,
                        message: Strings.ProInfo.Alert.buyProErrorMessage
                    )
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(storeManager.hasPurchasedPro || isLoading)
    }
    
    func buyPro() async throws {
        Logger.appStore.info("Buying Pro")
        guard let proProduct = storeManager.products.first(where: \.id, equals: JFLiterals.inAppPurchaseIDPro) else {
            throw PurchaseError.productNotFound
        }

        AnalyticsService.shared.track(
            .proPurchaseStarted(
                productID: .pro,
                price: NSDecimalNumber(decimal: proProduct.price).doubleValue
            )
        )
        
        // Execute the purchase
        let result = try await storeManager.purchase(proProduct)

        if result != nil {
            AnalyticsService.shared.track(
                .boughtPro(
                    productID: .pro,
                    price: NSDecimalNumber(decimal: proProduct.price).doubleValue
                )
            )
        }

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
