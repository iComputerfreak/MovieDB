// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Protects title-import dismissal with native confirmation and an older-system fallback.
struct TitleImportDismissalConfirmationModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool

    @ViewBuilder
    /// Applies native dismissal confirmation on iOS 27 and a button-driven compatibility dialog on older systems.
    /// - Parameter content: The title-import content whose presentation should be protected.
    /// - Returns: Content configured with the appropriate dismissal behavior for the running OS.
    func body(content: Content) -> some View {
        if #available(iOS 27.0, *) {
            content
                .dismissalConfirmationDialog(
                    Strings.TitleImport.DismissConfirmation.title,
                    shouldPresent: true
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
                .interactiveDismissDisabled()
        }
    }
}

extension View {
    /// Protects a title-import presentation from accidental dismissal.
    /// - Parameters:
    ///   - fallbackIsPresented: Controls the explicit confirmation dialog used before iOS 27.
    /// - Returns: A view with title-import dismissal protection applied.
    func titleImportDismissalConfirmationDialog(
        fallbackIsPresented: Binding<Bool>
    ) -> some View {
        modifier(
            TitleImportDismissalConfirmationModifier(isPresented: fallbackIsPresented)
        )
    }
}
