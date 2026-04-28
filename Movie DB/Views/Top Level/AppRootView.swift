//
//  AppRootView.swift
//  Movie DB
//
//  Created by OpenCode on 28.04.26.
//

import Analytics
import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var config: JFConfig

    @State private var isShowingAnalyticsConsent = JFConfig.shared.analyticsConsentState == .unknown
    @State private var pendingAnalyticsEnableSource: AnalyticsEnabledSource?

    var body: some View {
        Group {
            if isShowingAnalyticsConsent {
                Color.clear
                    .ignoresSafeArea()
            } else if config.language.isEmpty {
                LanguageChooser()
            } else {
                ContentView()
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
    }

    private func finalizeAnalyticsOptIn() {
        guard let source = pendingAnalyticsEnableSource else {
            return
        }

        AnalyticsService.shared.setTrackingEnabled(true)
        AnalyticsService.shared.track(.analyticsEnabled(source: source))
        pendingAnalyticsEnableSource = nil
    }
}
