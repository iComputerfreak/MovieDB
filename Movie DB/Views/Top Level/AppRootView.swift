// Copyright © 2026 Jonas Frey. All rights reserved.

import Analytics
import OSLog
import StoreKit
import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var config: JFConfig
    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) private var scenePhase

    @State private var isShowingAnalyticsConsent = JFConfig.shared.analyticsConsentState == .unknown
    @State private var isShowingChangelog = JFConfig.shared.analyticsConsentState != .unknown
        && Self.shouldPresentChangelog
    @State private var pendingAnalyticsEnableSource: AnalyticsEnabledSource?

    private static var shouldPresentChangelog: Bool {
        Changelog.shouldPresent()
            && !ProcessInfo.isRunningForPreviews
            && !CommandLine.launchArguments.contains(.uiTesting)
            && !CommandLine.launchArguments.contains(.screenshots)
    }

    private var changelogPresentation: Binding<Bool> {
        Binding {
            isShowingChangelog
        } set: { isPresented in
            isShowingChangelog = isPresented
            if !isPresented {
                Changelog.markCurrentAsSeen()
            }
        }
    }

    var body: some View {
        Group {
            if isShowingAnalyticsConsent {
                Color.clear
                    .ignoresSafeArea()
            } else if config.language.isEmpty {
                LanguageChooser()
            } else {
                ContentView()
                    .sheet(isPresented: changelogPresentation) {
                        ChangelogView()
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    }
            }
        }
        .sheet(isPresented: $isShowingAnalyticsConsent, onDismiss: finalizeAnalyticsOptIn) {
            AnalyticsConsentView(
                onAllow: {
                    pendingAnalyticsEnableSource = .onboarding
                    config.analyticsConsentState = .allowed
                    isShowingAnalyticsConsent = false
                },
                onKeepOff: {
                    config.analyticsConsentState = .denied
                    isShowingAnalyticsConsent = false
                }
            )
            .presentationDetents([.large])
            .interactiveDismissDisabled(config.analyticsConsentState == .unknown)
        }
        .task {
            AnalyticsService.shared.reloadFeatureFlags {
                Task { @MainActor in
                    AppStartup.shared.featureFlagsDidReload()
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                requestReviewIfNeeded()
            case .background:
                PersistenceController.saveContext()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }

    private func finalizeAnalyticsOptIn() {
        guard let source = pendingAnalyticsEnableSource else { return }

        AnalyticsService.shared.setTrackingEnabled(true)
        AnalyticsService.shared.reloadFeatureFlags {
            Task { @MainActor in
                AppStartup.shared.featureFlagsDidReload()
            }
        }
        AnalyticsService.shared.track(.analyticsEnabled(source: source))
        pendingAnalyticsEnableSource = nil
    }

    /// Requests an App Store review once after the app has been used for seven days.
    private func requestReviewIfNeeded() {
        let userDefaults = UserDefaults.standard
        guard userDefaults.integer(forKey: JFLiterals.Keys.askedForAppRating) == 0 else { return }
        guard let firstOpenDate = userDefaults.object(forKey: JFLiterals.Keys.firstAppOpenDate) as? Date else {
            userDefaults.set(Date.now, forKey: JFLiterals.Keys.firstAppOpenDate)
            return
        }
        guard abs(Date.now.distance(to: firstOpenDate)) > 7 * .day else { return }

        Logger.appStore.debug("Asking the user for an app store rating")
        requestReview()
        userDefaults.set(1, forKey: JFLiterals.Keys.askedForAppRating)
    }
}
