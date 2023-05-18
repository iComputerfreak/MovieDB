//
//  ProInfoView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

enum PurchaseError: Error {
    case productNotFound
}

struct ProInfoView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss
    
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
            .navigationTitle(Strings.ProInfo.navBarTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(Strings.ProInfo.restoreButtonLabel) {
                        Logger.appStore.info("Restoring Purchases")
                        Task {
                            do {
                                try await StoreManager.shared.restorePurchases()
                            } catch {
                                AlertHandler.showSimpleAlert(
                                    title: Strings.ProInfo.Alert.restoreFailedTitle,
                                    message: Strings.ProInfo.Alert.restoreFailedMessage(error.localizedDescription)
                                )
                            }
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.ProInfo.navBarButtonCancelLabel) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var buyButton: some View {
        if StoreManager.shared.hasPurchasedPro {
            Button(Strings.ProInfo.buyButtonLabelDisabled) {}
                .buttonStyle(.borderedProminent)
                .disabled(true)
        } else {
            let manager = StoreManager.shared
            let product = manager.products.first { $0.id == JFLiterals.inAppPurchaseIDPro }
            let displayPrice = product?.displayPrice ?? ""
            Button(Strings.ProInfo.buyButtonLabel(displayPrice)) {
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
            // TODO: Use custom buy button style hat incorporates the above if-case (see Apple's project)
                .buttonStyle(.borderedProminent)
        }
    }
    
    func buyPro() async throws {
        Logger.appStore.info("Buying Pro")
        guard let proProduct = StoreManager.shared.products.first(where: { product in
            product.id == JFLiterals.inAppPurchaseIDPro
        }) else {
            throw PurchaseError.productNotFound
        }
        
        // Execute the purchase
        let result = try await StoreManager.shared.purchase(proProduct)
        
        // Dismiss on a successful purchase
        if result != nil {
            dismiss()
        }
    }
}

struct ProInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProInfoView()
    }
}
