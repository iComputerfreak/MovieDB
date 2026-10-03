// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import WebKit

struct JFWebView: PlatformViewRepresentable {
    @Environment(\.openURL) private var openURL

    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(openURL: openURL)
    }

    private func makeWebView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)

        #if canImport(UIKit)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        #elseif canImport(AppKit)
        webView.underPageBackgroundColor = .clear
        #endif
        webView.navigationDelegate = context.coordinator

        return webView
    }

    private func updateWebView(_ webView: WKWebView) {
        guard webView.url != url else { return }

        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    #if canImport(UIKit)
    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.openURL = openURL
        updateWebView(webView)
    }
    #elseif canImport(AppKit)
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.openURL = openURL
        updateWebView(webView)
    }
    #endif

    /// Routes external navigation through SwiftUI's platform-aware URL action.
    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        var openURL: OpenURLAction

        /// Creates a navigation coordinator.
        /// - Parameter openURL: Action used for external links.
        init(openURL: OpenURLAction) {
            self.openURL = openURL
        }

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

            openURL(requestURL)
            decisionHandler(.cancel)
        }
    }
}

#Preview {
    JFWebView(url: URL(string: "https://jonasfrey.de")!)
}
