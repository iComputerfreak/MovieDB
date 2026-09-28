// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

/// Represents a button that dismisses the currently active view (e.g., a sheet)
struct ConfirmButton: View {
    @Environment(\.dismiss) private var dismiss
    private let onConfirm: (() -> Void)?

    private var confirmRole: ButtonRole? {
        if #available(iOS 26.0, *) {
            return .confirm
        } else {
            return nil
        }
    }

    init(onConfirm: (() -> Void)? = nil) {
        self.onConfirm = onConfirm
    }

    var body: some View {
        Button(
            Strings.Generic.dismissViewDone,
            systemImage: "checkmark",
            role: confirmRole,
            action: onConfirm ?? dismiss.callAsFunction
        )
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
                        ConfirmButton()
                    }
            }
        })
}
