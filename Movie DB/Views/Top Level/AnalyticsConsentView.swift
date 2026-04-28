//
//  AnalyticsConsentView.swift
//  Movie DB
//
//  Created by OpenCode on 28.04.26.
//

import SwiftUI

struct AnalyticsConsentView: View {
    let onAllow: () -> Void
    let onKeepOff: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(Strings.Settings.AnalyticsConsent.message)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(Strings.Settings.AnalyticsConsent.trackedHeader)
                            .font(.headline)

                        consentExampleRow(
                            title: Strings.Settings.AnalyticsConsent.trackedScreenViewsTitle,
                            detail: Strings.Settings.AnalyticsConsent.trackedScreenViewsDetail,
                            systemImage: "chart.bar"
                        )
                        consentExampleRow(
                            title: Strings.Settings.AnalyticsConsent.trackedFeatureUsageTitle,
                            detail: Strings.Settings.AnalyticsConsent.trackedFeatureUsageDetail,
                            systemImage: "slider.horizontal.3"
                        )
                        consentExampleRow(
                            title: Strings.Settings.AnalyticsConsent.trackedTechnicalContextTitle,
                            detail: Strings.Settings.AnalyticsConsent.trackedTechnicalContextDetail,
                            systemImage: "iphone"
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(Strings.Settings.AnalyticsConsent.notTrackedHeader)
                            .font(.headline)

                        consentExampleRow(
                            title: Strings.Settings.AnalyticsConsent.notTrackedMediaDataTitle,
                            detail: Strings.Settings.AnalyticsConsent.notTrackedMediaDataDetail,
                            systemImage: "film",
                            tint: .red
                        )
                        consentExampleRow(
                            title: Strings.Settings.AnalyticsConsent.notTrackedPersonalDataTitle,
                            detail: Strings.Settings.AnalyticsConsent.notTrackedPersonalDataDetail,
                            systemImage: "person.crop.circle.badge.xmark",
                            tint: .red
                        )
                    }

                    Text(Strings.Settings.AnalyticsConsent.worksWithoutAnalytics)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button(action: onAllow) {
                        Text(Strings.Settings.AnalyticsConsent.allowButton)
                            .bold()
                            .padding(4)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)

                    Button(action: onKeepOff) {
                        Text(Strings.Settings.AnalyticsConsent.keepOffButton)
                            .padding(4)
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.background)
            }
            .navigationTitle(Strings.Settings.AnalyticsConsent.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled()
    }

    private func consentExampleRow(
        title: String,
        detail: String,
        systemImage: String,
        tint: Color = .accentColor
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            AnalyticsConsentView(onAllow: {}, onKeepOff: {})
        }
}
