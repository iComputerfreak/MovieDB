//
//  DismissButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a button that dismisses the currently active view (e.g., a sheet)
struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    private let onDismiss: (() -> Void)?

    init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }

    var body: some View {
        Button {
            if let onDismiss {
                onDismiss()
            } else {
                dismiss()
            }
        } label: {
            Text(Strings.Generic.dismissViewDone)
                .bold()
        }
    }
}

#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true), content: {
            NavigationView {
                Text(verbatim: "Dismiss button does not work in preview due to constant binding.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .toolbar {
                        DismissButton()
                    }
            }
        })
}
