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
    @Environment(\.dismiss) private var dismiss

    let showCancelButton: Bool
    private let storeManager: StoreManager = .shared

    init(showCancelButton: Bool = true) {
        self.showCancelButton = showCancelButton
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text(Strings.ProInfo.introText(JFLiterals.nonProMediaLimit))
                    .frame(maxWidth: .infinity)
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
                        Button {
                            self.dismiss()
                        } label: {
                            Label(Strings.ProInfo.navBarButtonCancelLabel, systemImage: "xmark")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProInfoView()
        .previewEnvironment()
}
