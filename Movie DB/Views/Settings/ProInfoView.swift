//
//  ProInfoView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import SwiftUI

// TODO: Not correctly localized
struct ProInfoView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                HStack {
                    Text("Remove the limit of \(JFLiterals.nonProMediaLimit) objects by buying the Pro version " +
                         "of the app.")
                        .padding()
                    Spacer()
                }
                HStack {
                    Text("About me")
                        .font(.title)
                        .padding([.horizontal, .top])
                        .padding(.bottom, 2)
                    Spacer()
                }
                HStack {
                    // swiftlint:disable:next line_length
                    Text("Hi, my name is Jonas and I'm a student at the Karlsruher Institute of Technology in Karlsruhe, Germany. In my free time I make apps for fun and this app is one of those. It started as a personal project of mine in an endeavour to catalog all the movies and tv shows I ever watched, so I would be able to recommend good movies or shows to friends. The app has grown big enough and works good enough that I thought I would publish it on the App Store, so here we are.")
                        .padding(.horizontal)
                    Spacer()
                }
                Spacer()
                if Utils.purchasedPro() {
                    Text("Already Purchased")
                        .foregroundColor(.blue)
                } else {
                    Button("Buy Pro - $4.99") {
                        print("Buying Pro")
                        let manager = StoreManager.shared
                        guard let product = manager.products.first(where: { product in
                            product.productIdentifier == JFLiterals.inAppPurchaseIDPro
                        }) else {
                            AlertHandler.showSimpleAlert(
                                title: String(
                                    localized: "Unable to Purchase",
                                    // No way to split up a StaticString into multiple lines
                                    // swiftlint:disable:next line_length
                                    comment: "Title of an alert informing the user that there was an error with the in-app purchase"
                                ),
                                message: String(
                                    localized: "The requested In-App Purchase was not found.",
                                    // No way to split up a StaticString into multiple lines
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
