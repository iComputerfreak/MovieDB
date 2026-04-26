//
//  UnifiedSearchCoordinator.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.26.
//  Copyright © 2026 Jonas Frey. All rights reserved.
//

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
    var shouldOpenSearchTab = false

    func open(scope: UnifiedSearchScope, text: String = "") {
        self.text = text
        self.scope = scope
        shouldOpenSearchTab = true
    }
}
