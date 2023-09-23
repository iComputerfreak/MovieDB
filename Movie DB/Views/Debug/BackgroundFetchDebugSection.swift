//
//  BackgroundFetchDebugSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.04.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct BackgroundFetchDebugSection: View {
    var body: some View {
        Section("Background Fetch" as String) {
            let time = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "debug_lastBGFetchTime"))
            let cancelled = UserDefaults.standard.bool(forKey: "debug_lastBGFetchCancelled")
            let rescheduleResult = UserDefaults.standard.bool(forKey: "debug_lastBGFetchRescheduleResult")
            let result = UserDefaults.standard.bool(forKey: "debug_lastBGFetchResult")
            let lastLibraryUpdate = Date(timeIntervalSince1970: MediaLibrary.shared.lastUpdated)
            Text(
                verbatim: """
                Last BG Fetch was at \(time.formatted(.iso8601))
                Cancelled: \(cancelled ? "Yes" : "No")
                Rescheduled: \(rescheduleResult ? "Yes" : "No")
                Result: \(result ? "success" : "failure")
                Last Library Update: \(lastLibraryUpdate)
                """
            )
        }
    }
}

#Preview {
    BackgroundFetchDebugSection()
}
