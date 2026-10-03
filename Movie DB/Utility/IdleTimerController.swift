// Copyright © 2026 Jonas Frey. All rights reserved.

#if canImport(UIKit)
import UIKit
#endif

/// Temporarily controls platform idle-timer suppression for foreground work.
@MainActor
struct IdleTimerController {
    #if canImport(UIKit)
    private let previousState: Bool
    private let changedState: Bool
    #endif

    /// Optionally disables the idle timer while preserving its previous state.
    /// - Parameter shouldDisable: Whether idle-timer suppression is required.
    init(disabling shouldDisable: Bool) {
        #if canImport(UIKit)
        previousState = UIApplication.shared.isIdleTimerDisabled
        changedState = shouldDisable
        if shouldDisable {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        #endif
    }

    /// Restores the idle timer to its state before initialization.
    func restore() {
        #if canImport(UIKit)
        guard changedState else { return }
        UIApplication.shared.isIdleTimerDisabled = previousState
        #endif
    }
}
