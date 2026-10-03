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

struct SafariWebView: View {
    let url: URL

    var body: some View {
        WebView(url: url)
    }
}
#endif
