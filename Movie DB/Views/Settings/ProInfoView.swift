// Copyright © 2021 Jonas Frey. All rights reserved.

import os.log
import SwiftUI
import Analytics

enum PurchaseError: Error {
    case productNotFound
}

struct ProInfoView: View {
    @Environment(\.dismiss) private var dismiss

    let showCancelButton: Bool
    let source: AnalyticsProSheetSource
    private let storeManager: StoreManager = .shared

    init(showCancelButton: Bool = true, source: AnalyticsProSheetSource = .settings) {
        self.showCancelButton = showCancelButton
        self.source = source
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroCard
                    featuresCard
                    ctaCard
                }
                .padding(20)
            }
            .background(backgroundGradient.ignoresSafeArea())
            .navigationTitle(Strings.ProInfo.navBarTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(Strings.ProInfo.restoreButtonLabel) {
                        Logger.appStore.info("Restoring Purchases")
                        Task {
                            do {
                                try await storeManager.restorePurchases()
                                AnalyticsService.shared.track(.restoredPro)
                            } catch {
                                AlertHandler.showSimpleAlert(
                                    title: Strings.ProInfo.Alert.restoreFailedTitle,
                                    message: Strings.ProInfo.Alert.restoreFailedMessage(error.localizedDescription)
                                )
                            }
                        }
                    }
                }
                if showCancelButton {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            self.dismiss()
                        } label: {
                            Label(Strings.ProInfo.navBarButtonCancelLabel, systemImage: "xmark")
                        }
                    }
                }
            }
        }
        .task {
            AnalyticsService.shared.track(.proSheetViewed(source: source))
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.accentColor.opacity(0.12),
                Color.purple.opacity(0.08),
                Color.clear,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var heroCard: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 82, height: 82)

                Image(systemName: "sparkles.tv.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 10) {
                Text(Strings.ProInfo.navBarTitle)
                    .font(.title.bold())

                Text(Strings.ProInfo.introText(JFLiterals.nonProMediaLimit))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(cardBackground)
    }

    private var featuresCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.ProInfo.featuresTitle)
                .font(.headline)

            benefitRow(
                title: Strings.ProInfo.featureLibraryTitle,
                description: Strings.ProInfo.featureLibraryDescription(JFLiterals.nonProMediaLimit),
                systemImage: "square.stack.3d.up.fill",
                tint: .accentColor
            )

            benefitRow(
                title: Strings.ProInfo.featureUpcomingTitle,
                description: Strings.ProInfo.featureUpcomingDescription,
                systemImage: "calendar.badge.clock",
                tint: .orange
            )

            benefitRow(
                title: Strings.ProInfo.featureRestoreTitle,
                description: Strings.ProInfo.featureRestoreDescription,
                systemImage: "arrow.triangle.2.circlepath.circle.fill",
                tint: .green
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(cardBackground)
    }

    private var ctaCard: some View {
        VStack(spacing: 14) {
            Text(Strings.ProInfo.ctaTitle)
                .font(.headline)

            Text(Strings.ProInfo.ctaDescription)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            BuyProButton()
                .controlSize(.large)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.regularMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(.white.opacity(0.2))
            }
            .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
    }

    private func benefitRow(
        title: String,
        description: String,
        systemImage: String,
        tint: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            ProInfoView()
        }
        .previewEnvironment()
}
