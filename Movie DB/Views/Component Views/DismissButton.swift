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

    private var dismissRole: ButtonRole? {
        if #available(iOS 26.0, *) {
            return .close
        } else {
            return nil
        }
    }

    init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }

    var body: some View {
        Button(role: dismissRole) {
            (onDismiss ?? dismiss.callAsFunction)()
        } label: {
            Label {
                Text(Strings.Generic.dismissViewDone)
                    .bold()
            } icon: {
                Image(systemName: "xmark")
            }
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
