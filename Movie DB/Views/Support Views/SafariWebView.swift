// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

#if canImport(UIKit)
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.dismissButtonStyle = .close
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
#elseif canImport(AppKit)
import WebKit

struct SafariWebView: NSViewRepresentable {
    let url: URL

    /// Creates the web view used to display remote trailer content.
    /// - Parameter context: SwiftUI representable context.
    /// - Returns: Configured web view.
    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    /// Loads the requested URL when it changes.
    /// - Parameters:
    ///   - webView: Web view managed by SwiftUI.
    ///   - context: SwiftUI representable context.
    func updateNSView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }
}
#endif
