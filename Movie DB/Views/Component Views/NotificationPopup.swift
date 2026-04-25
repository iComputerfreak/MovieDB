//
//  NotificationPopup.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct NotificationPopup: View {
    @Binding var isPresented: Bool
    let image: Image
    let title: String
    let subtitle: String?
    let displayDuration: Double = 2
    
    // The size of the popup content
    private let popupSize: Double = 250
    // The percentage of height the image should take up (including image padding)
    private let imagePercentage: Double = 0.6
    // The size up to which the actual image will be scaled
    private let imageSize: Double = 75

    init(isPresented: Binding<Bool>, imageBuilder: () -> Image, title: String, subtitle: String? = nil) {
        self._isPresented = isPresented
        self.image = imageBuilder()
        self.title = title
        self.subtitle = subtitle
    }
    
    init(isPresented: Binding<Bool>, systemImage: String, title: String, subtitle: String? = nil) {
        self.init(
            isPresented: isPresented,
            imageBuilder: { Image(systemName: systemImage) },
            title: title,
            subtitle: subtitle
        )
    }
    
    var body: some View {
        VStack(spacing: 24) {
            image
                .resizable()
                .frame(width: imageSize, height: imageSize)
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.medium))
                if let subtitle {
                    Text(subtitle)
                }
            }
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.gray)
        .padding(32)
        .frame(maxWidth: 250)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .task { @MainActor in
            // Wait x seconds
            try? await Task.sleep(for: .seconds(displayDuration))
            // Dismiss view
            withAnimation {
                self.isPresented = false
            }
        }
        .opacity(isPresented ? 1 : 0)
    }
}

struct NotificationPopupModifier: ViewModifier {
    @Binding var isPresented: Bool
    let systemImage: String
    let title: String
    let subtitle: String?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                NotificationPopup(isPresented: $isPresented, systemImage: systemImage, title: title, subtitle: subtitle)
            }
    }
}

extension View {
    func notificationPopup(
        isPresented: Binding<Bool>,
        systemImage: String,
        title: String,
        subtitle: String? = nil
    ) -> some View {
        self.modifier(
            NotificationPopupModifier(
                isPresented: isPresented,
                systemImage: systemImage,
                title: title,
                subtitle: subtitle
            )
        )
    }
}

#Preview("Subtitle") {
    return NavigationStack {
        List {
            ForEach(0..<30) { i in
                Text(verbatim: "This is Item \(i)")
            }
        }
        .navigationTitle(Text(verbatim: "Favorites"))
    }
    .notificationPopup(
        isPresented: .constant(true),
        systemImage: "plus.circle",
        title: "Added to Playlist",
        subtitle: "1 song has been added to \"Watching.\""
    )
}

#Preview("Title only") {
    return NavigationStack {
        List {
            ForEach(0..<30) { i in
                Text(verbatim: "This is Item \(i)")
            }
        }
        .navigationTitle(Text(verbatim: "Favorites"))
    }
    .notificationPopup(
        isPresented: .constant(true),
        systemImage: "plus.circle",
        title: "Added to Playlist"
    )
}

#Preview("Fading") {
    @Previewable @State var isActive = true

    return NavigationStack {
        List {
            ForEach(0..<30) { i in
                Text(verbatim: "This is Item \(i)")
            }
        }
        .navigationTitle(Text(verbatim: "Favorites"))
    }
    .notificationPopup(
        isPresented: $isActive,
        systemImage: "plus.circle",
        title: "Added to Playlist",
        subtitle: "1 song has been added to \"Watching.\""
    )
    .task {
        await MainActor.run {
            isActive = true
        }
    }
}
