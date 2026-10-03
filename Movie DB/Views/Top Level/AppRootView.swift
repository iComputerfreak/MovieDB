// Copyright © 2026 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var config: JFConfig

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
                Task {
                    _ = BackgroundHandler().refreshBackgroundFetch()
                }
            }
        }
    }

    private func finalizeAnalyticsOptIn() {
        guard let source = pendingAnalyticsEnableSource else { return }

        AnalyticsService.shared.setTrackingEnabled(true)
        AnalyticsService.shared.reloadFeatureFlags {
            Task {
                _ = BackgroundHandler().refreshBackgroundFetch()
            }
        }
        AnalyticsService.shared.track(.analyticsEnabled(source: source))
        pendingAnalyticsEnableSource = nil
    }
}
