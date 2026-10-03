// Copyright © 2022 Jonas Frey. All rights reserved.

import os.log
import SwiftUI
import TipKit
import Analytics

#if DEBUG
private let analyticsAppEnvironment = "debug"
#else
private let analyticsAppEnvironment = "release"
#endif

extension ProcessInfo {
    static var isRunningForPreviews: Bool {
        #if DEBUG
        return processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}

@main
struct MovieDBApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    @ObservedObject private var config = JFConfig.shared

    init() {
        if !ProcessInfo.isRunningForPreviews {
            AnalyticsService.shared.configure(
                AnalyticsConfiguration(
                    apiKey: Secrets.postHogProjectToken,
                    host: Secrets.postHogHost,
                    isTrackingEnabled: JFConfig.shared.isAnalyticsEnabled,
                    distinctID: JFConfig.shared.analyticsInstallationID,
                    personProperties: analyticsPersonProperties,
                    personPropertiesSetOnce: analyticsPersonPropertiesSetOnce
                )
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(
                    \.managedObjectContext,
                    ProcessInfo.isRunningForPreviews
                      ? PersistenceController.xcodePreviewContext
                      : PersistenceController.viewContext
                )
                .environmentObject(config)
            // Respond to universal links
            .openShareURLModifier()
            .task {
                do {
                    try Tips.configure()
                } catch {
                    Logger.tips.error("Failed to configure TipKit: \(error)")
                }
            }
        }
    }
}

private var analyticsPersonProperties: [String: String] {
    [
        "app_environment": analyticsAppEnvironment,
    ]
}

private var analyticsPersonPropertiesSetOnce: [String: String] {
    [:]
}

private enum AppVersion {
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    static let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
}
