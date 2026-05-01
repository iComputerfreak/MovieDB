// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct AnalyticsSection: View {
    @EnvironmentObject var preferences: JFConfig

    let enableAnalyticsHandler: () -> Void
    let disableAnalyticsHandler: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(Strings.Settings.analyticsLabel)
                    Spacer()
                    Text(
                        // swiftlint:disable:next line_length
                        preferences.isAnalyticsEnabled ? Strings.Settings.analyticsStatusOn : Strings.Settings.analyticsStatusOff
                    )
                    .foregroundStyle(.secondary)
                }

                Text(Strings.Settings.analyticsSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button(
                // swiftlint:disable:next line_length
                preferences.isAnalyticsEnabled ? Strings.Settings.analyticsDisableButton : Strings.Settings.analyticsEnableButton,
                action: preferences.isAnalyticsEnabled ? disableAnalyticsHandler : enableAnalyticsHandler
            )
            .tint(preferences.isAnalyticsEnabled ? .red : .accentColor)
        } header: {
            Text(Strings.Settings.analyticsSectionHeader)
        } footer: {
            FooterView()
        }
    }
}

struct FooterView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                // Made with love footer
                Text(Strings.Settings.madeWithLoveFooter)
                    .bold()
                // App version
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Text(Strings.Settings.versionFooter(appVersion))
                        .italic()
                }
            }
            Spacer()
        }
    }
}

#Preview {
    List {
        AnalyticsSection(
            enableAnalyticsHandler: {},
            disableAnalyticsHandler: {}
        )
        .previewEnvironment()
    }
}
