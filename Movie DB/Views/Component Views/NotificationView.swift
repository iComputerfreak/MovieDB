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
    var contentBuilder: (NotificationProxy) -> Content
    
    @StateObject private var proxy = NotificationProxy()
    
    // swiftlint:disable:next type_contents_order
    init(contentBuilder: @escaping (NotificationProxy) -> Content) {
        self.contentBuilder = contentBuilder
    }
    
    var body: some View {
        contentBuilder(proxy)
            .notificationPopup(
                isPresented: $proxy.isDisplayed,
                systemImage: proxy.systemImage,
                title: proxy.title,
                subtitle: proxy.subtitle
            )
    }
}

/// Represents a proxy used to propagate the information to display in a notification popup from the ``NotificationView``'s content to the NotificationView itself.
///
/// Use ``show(title:subtitle:systemImage:)`` to set the required data.
class NotificationProxy: ObservableObject {
    @Published fileprivate var isDisplayed = false
    fileprivate var title: String = ""
    fileprivate var subtitle: String?
    fileprivate var systemImage: String = ""
    
    func show(title: String, subtitle: String? = nil, systemImage: String) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isDisplayed = true
    }
}

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
                            proxy.show(
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
