// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

extension View {
    /// Presents an alert for an error using the app's generic error title.
    /// - Parameter error: Error to present. Dismissing the alert clears the binding.
    /// - Returns: A view that presents the error alert.
    func errorAlert(error: Binding<(any Error)?>) -> some View {
        alert(
            Strings.Generic.alertErrorTitle,
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            ),
            presenting: error.wrappedValue
        ) { _ in
            Button(Strings.Generic.alertButtonOk) {}
        } message: { error in
            Text(verbatim: (error as? DecodingError)?.diagnosticDescription ?? error.localizedDescription)
        }
    }

    /// Presents a message alert while the supplied state is true.
    /// - Parameters:
    ///   - title: Alert title.
    ///   - message: Optional alert message.
    ///   - isPresented: Whether the alert is visible.
    /// - Returns: A view that presents the message alert.
    func messageAlert(title: String, message: String?, isPresented: Binding<Bool>) -> some View {
        alert(title, isPresented: isPresented) {
            Button(Strings.Generic.alertButtonOk) {}
        } message: {
            if let message {
                Text(verbatim: message)
            }
        }
    }

    /// Presents an alert while a message exists and clears it when dismissed.
    /// - Parameters:
    ///   - title: Alert title.
    ///   - message: Message to present. Dismissing the alert clears the binding.
    /// - Returns: A view that presents the message alert.
    func messageAlert(title: String, message: Binding<String?>) -> some View {
        alert(
            title,
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
            ),
            presenting: message.wrappedValue
        ) { _ in
            Button(Strings.Generic.alertButtonOk) {}
        } message: { message in
            Text(verbatim: message)
        }
    }

    /// Presents a destructive confirmation alert.
    /// - Parameters:
    ///   - title: Alert title.
    ///   - message: Alert message.
    ///   - destructiveButtonTitle: Destructive action title.
    ///   - isPresented: Whether the alert is visible.
    ///   - action: Action invoked after destructive confirmation.
    /// - Returns: A view that presents the destructive alert.
    func destructiveAlert(
        title: String = Strings.Generic.alertDeleteTitle,
        message: String = Strings.Generic.alertDeleteMessage,
        destructiveButtonTitle: String = Strings.Generic.alertDeleteButtonTitle,
        isPresented: Binding<Bool>,
        action: @escaping () -> Void
    ) -> some View {
        alert(title, isPresented: isPresented) {
            Button(Strings.Generic.alertButtonCancel, role: .cancel) {}
            Button(destructiveButtonTitle, role: .destructive, action: action)
        } message: {
            Text(verbatim: message)
        }
    }
}
