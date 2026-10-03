// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import WebKit

struct PrivacyPolicyView: View {
    @EnvironmentObject private var config: JFConfig

    @State private var selectedLanguage: PrivacyPolicyLanguage = .english
    @State private var didApplyPreferredLanguage = false

    private enum PrivacyPolicyLanguage: String, CaseIterable, Identifiable {
        case english
        case german

        var id: String { rawValue }

        var bundleResourceName: String {
            switch self {
            case .english:
                "PrivacyPolicy"
            case .german:
                "PrivacyPolicy.de"
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
                ForEach(PrivacyPolicyLanguage.allCases) { language in
                    Text(language.title)
                        .tag(language)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)

            if let policyURL {
                JFWebView(url: policyURL)
            } else {
                ContentUnavailableView(
                    Strings.Legal.privacyPolicyTitle,
                    systemImage: "doc.text",
                    description: Text(Strings.Legal.privacyPolicyLoadError)
                )
            }
        }
        .navigationTitle(Strings.Legal.privacyPolicyTitle)
        .inlineNavigationTitle()
        .onAppear {
            guard !didApplyPreferredLanguage else { return }

            selectedLanguage = preferredLanguage
            didApplyPreferredLanguage = true
        }
    }

    private var preferredLanguage: PrivacyPolicyLanguage {
        if config.language.lowercased().hasPrefix("de") {
            return .german
        }

        if Locale.current.language.languageCode?.identifier == "de" {
            return .german
        }

        return .english
    }

    private var policyURL: URL? {
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
        PrivacyPolicyView()
            .environmentObject(JFConfig.shared)
    }
}
