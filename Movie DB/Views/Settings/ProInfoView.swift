//
//  ProInfoView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProInfoView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                HStack {
                    Text(Strings.ProInfo.introText(JFLiterals.nonProMediaLimit))
                        .padding()
                    Spacer()
                }
                HStack {
                    Text(Strings.ProInfo.aboutMeHeader)
                        .font(.title)
                        .padding([.horizontal, .top])
                        .padding(.bottom, 2)
                    Spacer()
                }
                HStack {
                    Text(Strings.ProInfo.aboutMeText)
                        .padding(.horizontal)
                    Spacer()
                }
                Spacer()
                if Utils.purchasedPro() {
                    Button(Strings.ProInfo.buyButtonLabelDisabled) {}
                        .buttonStyle(.borderedProminent)
                        .disabled(true)
                } else {
                    // TODO: Localize price
                    Button(Strings.ProInfo.buyButtonLabel) {
                        print("Buying Pro")
                        let manager = StoreManager.shared
                        guard let product = manager.products.first(where: { product in
                            product.productIdentifier == JFLiterals.inAppPurchaseIDPro
                        }) else {
                            AlertHandler.showSimpleAlert(
                                title: Strings.ProInfo.Alert.buyProErrorMessage,
                                message: Strings.ProInfo.Alert.buyProErrorMessage
                            )
                            return
                        }
                        // Execute the purchase
                        StoreManager.shared.purchase(product: product)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle(Strings.ProInfo.navBarTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(Strings.ProInfo.restoreButtonLabel) {
                        print("Restoring Purchases")
                        StoreManager.shared.restorePurchases()
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
}

struct ProInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProInfoView()
    }
}
