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
    // Padding is applied additionally to the popupSize! The final size will be `popupSize + 2 2 * padding`
    private let padding: Double = 6
    
    // swiftlint:disable:next type_contents_order
    init(isPresented: Binding<Bool>, imageBuilder: () -> Image, title: String, subtitle: String? = nil) {
        self._isPresented = isPresented
        self.image = imageBuilder()
        self.title = title
        self.subtitle = subtitle
    }
    
    // swiftlint:disable:next type_contents_order
    init(isPresented: Binding<Bool>, systemImage: String, title: String, subtitle: String? = nil) {
        self.init(
            isPresented: isPresented,
            imageBuilder: { Image(systemName: systemImage) },
            title: title,
            subtitle: subtitle
        )
    }
    
    var body: some View {
        if isPresented {
            VStack(spacing: 0) {
                image
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .frame(height: imagePercentage * popupSize)
                VStack(alignment: .center) {
                    Text(title)
                        .font(.title2.weight(.medium))
                    if let subtitle {
                        Text(subtitle)
                    }
                    Spacer()
                }
                .multilineTextAlignment(.center)
                // Text takes the rest of the popup size
                .frame(maxHeight: (1 - imagePercentage) * popupSize)
            }
            .foregroundColor(.gray)
            .frame(width: popupSize, height: popupSize)
            .padding(padding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            .task {
                print("Waiting")
                // Wait x seconds
                try? await Task.sleep(nanoseconds: UInt64(displayDuration * 1_000_000_000))
                // Dismiss view
                await MainActor.run {
                    withAnimation {
                        self.isPresented = false
                    }
                    print("Dismissed")
                }
            }
        } else {
            EmptyView()
        }
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

struct NotificationPopup_Previews: PreviewProvider {
    @State static var isActive = true
    
    static var previews: some View {
        Preview()
    }
}

private struct Preview: View {
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<30) { i in
                    Text("This is Item \(i)")
                }
            }
            .navigationTitle("Favorites")
        }
        .notificationPopup(
            isPresented: $isActive,
            systemImage: "plus.circle",
            title: "Added to Playlist",
            subtitle: "1 song has been added to \"Discord.\""
        )
        .task {
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                self.isActive = true
            }
        }
    }
}
