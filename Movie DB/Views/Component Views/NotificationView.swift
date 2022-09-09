//
//  NotificationView.swift
//  Movie DB
//
//  Created by Jonas Frey on 09.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a wrapper view that surrounds the main content of a screen
///
/// The `NotificationView` provides a proxy that can be used to display notifications. Call ``NotificationProxy/show(title:subtitle:systemImage:)`` to present a notification popup over the main content.
struct NotificationView<Content: View>: View {
    var contentBuilder: (Binding<NotificationProxy>) -> Content
    
    @State private var proxy: NotificationProxy
    
    // swiftlint:disable:next type_contents_order
    init(contentBuilder: @escaping (Binding<NotificationProxy>) -> Content) {
        self.contentBuilder = contentBuilder
        self.proxy = NotificationProxy()
    }
    
    var body: some View {
        contentBuilder($proxy)
            .notificationPopup(
                isPresented: $proxy.isDisplayed,
                systemImage: proxy.systemImage,
                title: proxy.title,
                subtitle: proxy.subtitle
            )
    }
}

// swiftlint:disable file_types_order
/// Represents a proxy used to propagate the information to display in a notification popup from the ``NotificationView``'s content to the NotificationView itself.
///
/// Use ``show(title:subtitle:systemImage:)`` to set the required data.
struct NotificationProxy {
    fileprivate var isDisplayed = false
    fileprivate var title: String = ""
    fileprivate var subtitle: String?
    fileprivate var systemImage: String = ""
    
    mutating func show(title: String, subtitle: String? = nil, systemImage: String) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isDisplayed = true
    }
}
// swiftlint:enable file_types_order

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView { proxy in
            NavigationView {
                List {
                    ForEach(0..<10) { i in
                        Text(verbatim: "This is item \(i)")
                    }
                    .task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        await MainActor.run {
                            proxy.wrappedValue.show(
                                title: "Test",
                                subtitle: "This is a test notification.",
                                systemImage: "checkmark.circle.fill"
                            )
                        }
                    }
                }
            }
        }
    }
}
