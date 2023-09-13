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
    let showCancelButton: Bool
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
                BuyProButton()
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
                            self.dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct ProInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProInfoView()
            .previewEnvironment()
    }
}
