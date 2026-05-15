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
                PrivacyPolicyWebView(url: policyURL)
            } else {
                ContentUnavailableView(
                    Strings.Legal.privacyPolicyTitle,
                    systemImage: "doc.text",
                    description: Text(Strings.Legal.privacyPolicyLoadError)
                )
            }
        }
        .navigationTitle(Strings.Legal.privacyPolicyTitle)
        .navigationBarTitleDisplayMode(.inline)
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

private struct PrivacyPolicyWebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)

        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.navigationDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }

        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
        ) {
            guard let requestURL = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            if requestURL.isFileURL {
                decisionHandler(.allow)
                return
            }

            UIApplication.shared.open(requestURL)
            decisionHandler(.cancel)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
            .environmentObject(JFConfig.shared)
    }
}
