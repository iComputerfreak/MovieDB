// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import WebKit

struct ImprintView: View {
    @EnvironmentObject private var config: JFConfig

    @State private var selectedLanguage: ImprintLanguage = .english
    @State private var didApplyPreferredLanguage = false

    private enum ImprintLanguage: String, CaseIterable, Identifiable {
        case english
        case german

        var id: String { rawValue }

        var bundleResourceName: String {
            switch self {
            case .english:
                "Imprint"
            case .german:
                "Imprint.de"
            }
        }

        var title: String {
            switch self {
            case .english:
                Strings.Legal.privacyPolicyLanguageEnglish
            case .german:
                Strings.Legal.privacyPolicyLanguageGerman
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker(Strings.Legal.privacyPolicyLanguagePickerTitle, selection: $selectedLanguage) {
                ForEach(ImprintLanguage.allCases) { language in
                    Text(language.title)
                        .tag(language)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)

            if let imprintURL {
                JFWebView(url: imprintURL)
            } else {
                ContentUnavailableView(
                    Strings.Legal.imprintTitle,
                    systemImage: "doc.text",
                    description: Text(Strings.Legal.imprintLoadError)
                )
            }
        }
        .navigationTitle(Strings.Legal.imprintTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !didApplyPreferredLanguage else { return }

            selectedLanguage = preferredLanguage
            didApplyPreferredLanguage = true
        }
    }

    private var preferredLanguage: ImprintLanguage {
        if config.language.lowercased().hasPrefix("de") {
            return .german
        }

        if Locale.current.language.languageCode?.identifier == "de" {
            return .german
        }

        return .english
    }

    private var imprintURL: URL? {
        if let url = Bundle.main.url(
            forResource: selectedLanguage.bundleResourceName,
            withExtension: "html",
            subdirectory: "Legal"
        ) {
            return url
        }

        return Bundle.main.url(
            forResource: selectedLanguage.bundleResourceName,
            withExtension: "html"
        )
    }
}

#Preview {
    NavigationStack {
        ImprintView()
            .environmentObject(JFConfig.shared)
    }
}
