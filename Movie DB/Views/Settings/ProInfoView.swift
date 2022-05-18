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
                    Text(
                        "proInfo.introText \(JFLiterals.nonProMediaLimit)",
                        // swiftlint:disable:next line_length
                        comment: "Text in pro info view that explains the media limit which buying pro removes. The parameter is the amount of objects one can add in the free version"
                    )
                        .padding()
                    Spacer()
                }
                HStack {
                    Text(
                        "proInfo.aboutMe.header",
                        comment: "The header of the 'about me' paragraph in the pro info view"
                    )
                        .font(.title)
                        .padding([.horizontal, .top])
                        .padding(.bottom, 2)
                    Spacer()
                }
                HStack {
                    Text(
                        "proInfo.aboutMe.text",
                        comment: "The 'about me' text in the pro info view"
                    )
                        .padding(.horizontal)
                    Spacer()
                }
                Spacer()
                if Utils.purchasedPro() {
                    Button(String(
                        localized: "proInfo.buyButton.label.disabled",
                        comment: "The button label in the pro info view indicating that the user already bought pro."
                    )) {}
                        .buttonStyle(.borderedProminent)
                        .disabled(true)
                } else {
                    // TODO: Localize price
                    Button(String(
                        localized: "proInfo.buyButton.label \("4,99 $")",
                        // swiftlint:disable:next line_length
                        comment: "The button label in the pro info view displaying the price to buy the pro version of the app. The parameter is the localized and formatted price."
                    )) {
                        print("Buying Pro")
                        let manager = StoreManager.shared
                        guard let product = manager.products.first(where: { product in
                            product.productIdentifier == JFLiterals.inAppPurchaseIDPro
                        }) else {
                            AlertHandler.showSimpleAlert(
                                title: String(
                                    localized: "settings.alert.errorBuyingPro.title",
                                    // swiftlint:disable:next line_length
                                    comment: "Title of an alert informing the user that there was an error with the in-app purchase"
                                ),
                                message: String(
                                    localized: "settings.alert.errorBuyingPro.message",
                                    // swiftlint:disable:next line_length
                                    comment: "Message of an alert informing the user that the purchase could not be completed because the in-app purchase could not be found / is not configured"
                                )
                            )
                            return
                        }
                        // Execute the purchase
                        StoreManager.shared.purchase(product: product)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Movie DB Pro")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Restore") {
                        print("Restoring Purchases")
                        StoreManager.shared.restorePurchases()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ProInfoView_Previews: PreviewProvider {
    @State private static var isShowing = true
    
    static var previews: some View {
        ProInfoView()
    }
}
