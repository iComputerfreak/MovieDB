// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

struct BackgroundFetchDebugSection: View {
    var body: some View {
        Section("Background Fetch" as String) {
            let debugState = BackgroundHandler.debugState
            let time = debugState.lastRunTime?.formatted(.iso8601) ?? "never"
            let cancelled = debugState.lastCancelled == true
            let rescheduleResult = debugState.lastRescheduleResult.rawValue
            let result = debugState.lastResult.rawValue
            let resolvedInterval = debugState.lastResolvedInterval
            let lastErrorDescription = debugState.lastErrorDescription ?? "none"
            let lastLibraryUpdate = Date(timeIntervalSince1970: MediaLibrary.shared.lastUpdated)
            let currentInterval = BackgroundHandler.currentBackgroundUpdateInterval
            let currentState = currentInterval == nil ? "disabled" : "enabled"
            let intervalDescription = resolvedInterval.map(Self.intervalDescription) ?? "n/a"
            let currentIntervalDescription = currentInterval.map(Self.intervalDescription) ?? "n/a"
            Text(
                verbatim: """
                Current State: \(currentState)
                Current Interval: \(currentIntervalDescription)
                Last BG Fetch was at \(time)
                Cancelled: \(cancelled ? "Yes" : "No")
                Last Reschedule Result: \(rescheduleResult)
                Last Resolved Interval: \(intervalDescription)
                Last Execution Result: \(result)
                Last Error: \(lastErrorDescription)
                Last Library Update: \(lastLibraryUpdate)
                """
            )
        }
    }

    private static func intervalDescription(_ interval: TimeInterval) -> String {
        let hours = interval / 60 / 60
        return "\(hours.formatted(.number.precision(.fractionLength(0...2))))h"
    }
}

#Preview {
    BackgroundFetchDebugSection()
}
