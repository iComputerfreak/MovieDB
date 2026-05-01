// Copyright © 2021 Jonas Frey. All rights reserved.

import os.log
import SwiftUI

struct LanguageChooser: View {
    @EnvironmentObject private var config: JFConfig
    @State private var loadError: Error?
    @State private var loadTaskID = UUID()
    
    var proxy: Binding<String?> {
        .init(get: { config.language }, set: { config.language = $0 ?? "" })
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if config.availableLanguages.isEmpty {
                    if let loadError {
                        ScreenUnavailableView(
                            title: Strings.LanguageChooser.Alert.errorLoadingTitle,
                            systemImage: "globe.badge.chevron.backward",
                            error: loadError,
                            actionTitle: Strings.Generic.retryLoading,
                            action: retryLoading
                        )
                    } else {
                        ScreenLoadingView(
                            title: Strings.LanguageChooser.navBarTitle,
                            message: Strings.LanguageChooser.loadingText
                        )
                    }
                } else {
                    VStack(spacing: 8) {
                        CalloutView(text: Strings.LanguageChooser.callout, type: .info)
                            .padding(.horizontal)
                        List(selection: proxy) {
                            ForEach(config.availableLanguages, id: \.self) { (code: String) in
                                Text(Locale.current.localizedString(forIdentifier: code) ?? code)
                                    .tag(code)
                            }
                        }
                        .safeAreaPadding(.top, 8)
                    }
                    .environment(\.editMode, .constant(.active))
                    .onChange(of: config.language) { _, _ in
                        Logger.settings.info("Language changed to \(config.language, privacy: .public)")
                    }
                }
            }
            .navigationTitle(Strings.LanguageChooser.navBarTitle)
        }
        .task(id: loadTaskID, priority: .userInitiated) {
            await loadLanguages()
        }
    }

    @MainActor
    private func loadLanguages() async {
        guard config.availableLanguages.isEmpty else { return }

        loadError = nil

        do {
            try await Utils.updateTMDBLanguages()
        } catch {
            loadError = error
        }
    }

    private func retryLoading() {
        loadTaskID = UUID()
    }
}

#Preview {
    LanguageChooser()
        .previewEnvironment()
}
