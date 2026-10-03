// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import WebKit

struct JFWebView: PlatformViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
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
        updateWebView(webView)
    }
    #elseif canImport(AppKit)
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        updateWebView(webView)
    }
    #endif

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

            #if canImport(UIKit)
            UIApplication.shared.open(requestURL)
            #else
            NSWorkspace.shared.open(requestURL)
            #endif
            decisionHandler(.cancel)
        }
    }
}

#Preview {
    JFWebView(url: URL(string: "https://jonasfrey.de")!)
}
