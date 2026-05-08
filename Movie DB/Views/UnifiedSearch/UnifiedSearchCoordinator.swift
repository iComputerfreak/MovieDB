// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

@MainActor
@Observable
final class UnifiedSearchCoordinator {
    struct Route: Equatable {
        let text: String
        let scope: UnifiedSearchScope
    }

    var text = ""
    var scope: UnifiedSearchScope = .library
    var isPresented = false
    var shouldOpenSearchTab = false

    func open(scope: UnifiedSearchScope, text: String = "") {
        self.text = text
        self.scope = scope
        isPresented = true
        shouldOpenSearchTab = true
    }

    func dismiss() {
        text = ""
        isPresented = false
    }
}
