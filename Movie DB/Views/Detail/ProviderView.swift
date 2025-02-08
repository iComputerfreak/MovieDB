//
//  ProviderView.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProviderView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var provider: WatchProvider

    let iconSize: CGFloat
    let showTypeLabel: Bool

    init(provider: WatchProvider, iconSize: CGFloat = 45, showTypeLabel: Bool = true) {
        self.provider = provider
        self.iconSize = iconSize
        self.showTypeLabel = showTypeLabel
    }

    var body: some View {
        VStack {
            Group {
                if let image = provider.logoImage {
                    Image(uiImage: image)
                        .resizable()
                        .cornerRadius(0.2 * iconSize)
                        .shadow(radius: 1, y: 1.5)
                } else {
                    placeholderView(for: provider)
                }
            }
            .frame(width: iconSize, height: iconSize)
            .padding(2)

            if showTypeLabel {
                Text(provider.type?.localized ?? "")
                    .font(.caption)
            }
        }
    }
    
    func placeholderView(for provider: WatchProvider) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.quaternary)
            .shadow(radius: 1, y: 1.5)
            .overlay {
                Text(provider.name)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 9))
                    .padding(1)
            }
    }
}

#Preview {
    HStack {
        ProviderView(provider: PlaceholderData.preview.staticMovie.watchProviders.sorted(on: \.name, by: <).first!)
        ProviderView(provider: PlaceholderData.preview.staticMovie.watchProviders.sorted(on: \.name, by: <).last!)
    }
}
