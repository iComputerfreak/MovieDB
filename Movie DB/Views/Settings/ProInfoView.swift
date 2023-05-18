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
    @EnvironmentObject private var storeManager: StoreManager
    
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
        if storeManager.hasPurchasedPro {
            Button(Strings.ProInfo.buyButtonLabelDisabled) {}
                .buttonStyle(.borderedProminent)
                .disabled(true)
        } else {
            let product = storeManager.products.first(where: \.id, equals: JFLiterals.inAppPurchaseIDPro)
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

struct ProInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProInfoView()
            .previewEnvironment()
    }
}
