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
                    Text("Remove the limit of \(JFLiterals.nonProMediaLimit) objects by buying the Pro version of the app.")
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
                    Text("Hi, my name is Jonas and I'm a student at the Karlsruher Institute of Technology in Karlsruhe, Germany. In my free time I make apps for fun and this app is one of those. It started as a personal project of mine in an endeavour to catalog all the movies and tv shows I ever watched, so I would be able to recommend good movies or shows to friends. The app has grown big enough and works good enough that I thought I would publish it on the App Store, so here we are.")
                        .padding(.horizontal)
                    Spacer()
                }
                Spacer()
                // TODO: Make new button style (rounded)
                if Utils.purchasedPro() {
                    Text("Already Purchased")
                        .foregroundColor(.blue)
                } else {
                    Button("Buy Pro - $4.99") {
                        // TODO: Implement
                        print("Buying Pro")
                        let manager = StoreManager.shared
                        guard let product = manager.products.first(where: { $0.productIdentifier == JFLiterals.inAppPurchaseIDPro }) else {
                            AlertHandler.showSimpleAlert(title: NSLocalizedString("Unable to Purchase"), message: NSLocalizedString("The requested In-App Purchase was not found."))
                            return
                        }
                        // Execute the purchase
                        StoreManager.shared.purchase(product: product)
                    }
                }
            }
            .navigationTitle("Movie DB Pro")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Restore") {
                        // TODO: Implement
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
    
    @State private static var isShowing: Bool = true
    
    static var previews: some View {
        Text("Hello, world!")
            .popover(isPresented: $isShowing, content: {
                ProInfoView()
            })
    }
}
