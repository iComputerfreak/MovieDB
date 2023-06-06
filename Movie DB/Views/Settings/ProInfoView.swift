//
//  ProInfoView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import os.log
import StoreKit
import SwiftUI

enum PurchaseError: Error {
    case productNotFound
}

struct ProInfoView: View {
    let showCancelButton: Bool
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager
    
    init(showCancelButton: Bool = true) {
        self.showCancelButton = showCancelButton
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                HStack {
                    Text(Strings.ProInfo.introText(JFLiterals.nonProMediaLimit))
                        .padding()
                    Spacer()
                }
                Spacer()
                buyButton
            }
            .padding()
            .navigationTitle(Strings.ProInfo.navBarTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(Strings.ProInfo.restoreButtonLabel) {
                        Logger.appStore.info("Restoring Purchases")
                        Task {
                            do {
                                try await storeManager.restorePurchases()
                            } catch {
                                AlertHandler.showSimpleAlert(
                                    title: Strings.ProInfo.Alert.restoreFailedTitle,
                                    message: Strings.ProInfo.Alert.restoreFailedMessage(error.localizedDescription)
                                )
                            }
                        }
                    }
                }
                if showCancelButton {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Strings.ProInfo.navBarButtonCancelLabel) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    var proProduct: Product? {
        storeManager.products.first(where: \.id, equals: JFLiterals.inAppPurchaseIDPro)
    }
    
    @ViewBuilder
    var buyButton: some View {
        if let product = proProduct {
            GroupBox {
                ProductView(product, prefersPromotionalIcon: true)
                    .productViewStyle(.large)
                    .frame(maxWidth: .infinity)
                    .onInAppPurchaseCompletion { _, result in
                        handleInAppPurchaseResult(result)
                    }
            }
        }
    }
    
    func handleInAppPurchaseResult(_ result: Result<Product.PurchaseResult, Error>) {
        Task(priority: .userInitiated) {
            do {
                let purchaseResult = try await storeManager.handleInAppPurchaseResult(result)
                switch purchaseResult {
                case .success, .pending:
                    dismiss()
                case .userCancelled:
                    break
                @unknown default:
                    assertionFailure("Unknown purchase result \(purchaseResult)")
                }
                dismiss()
            } catch {
                print(error)
                AlertHandler.showSimpleAlert(
                    title: Strings.ProInfo.Alert.buyProErrorMessage,
                    message: Strings.ProInfo.Alert.buyProErrorMessage
                )
            }
        }
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
    ProInfoView()
        .previewEnvironment()
}
