// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportDismissalConfirmationModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    let shouldPresent: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 27.0, *) {
            content.dismissalConfirmationDialog(
                Strings.TitleImport.DismissConfirmation.title,
                shouldPresent: shouldPresent
            ) {
                Button(Strings.TitleImport.DismissConfirmation.abort, role: .destructive) {}
                Button(Strings.Generic.alertButtonCancel, role: .cancel) {}
            } message: {
                Text(Strings.TitleImport.DismissConfirmation.message)
            }
        } else {
            content
                .confirmationDialog(
                    Strings.TitleImport.DismissConfirmation.title,
                    isPresented: $isPresented,
                    titleVisibility: .visible
                ) {
                    Button(Strings.TitleImport.DismissConfirmation.abort, role: .destructive) {
                        dismiss()
                    }
                    Button(Strings.Generic.alertButtonCancel, role: .cancel) {}
                } message: {
                    Text(Strings.TitleImport.DismissConfirmation.message)
                }
                .interactiveDismissDisabled(shouldPresent)
        }
    }
}

extension View {
    func titleImportDismissalConfirmationDialog(
        shouldPresent: Bool,
        fallbackIsPresented: Binding<Bool>
    ) -> some View {
        modifier(
            TitleImportDismissalConfirmationModifier(
                isPresented: fallbackIsPresented,
                shouldPresent: shouldPresent
            )
        )
    }
}
