//
//  ProviderView.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProviderView: View {
    @ObservedObject var provider: WatchProvider
    @Environment(\.colorScheme) var colorScheme
    
    let iconSize: CGFloat = 45
    
    var body: some View {
        VStack {
            Group {
                if let image = provider.logoImage {
                    Image(uiImage: image)
                        .resizable()
                        .cornerRadius(10)
                        .shadow(radius: 1, y: 1.5)
                } else {
                    placeholderView(for: provider)
                }
            }
            .frame(width: iconSize, height: iconSize)
            .padding(2)
            
            Text(provider.type?.localized ?? "")
                .font(.caption)
        }
    }
    
    func placeholderView(for provider: WatchProvider) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.quaternary)
            .shadow(radius: 1, y: 1.5)
            .overlay {
                Text(provider.name)
                    .multilineTextAlignment(.center)
                    .font(.caption2)
            }
    }
}

struct ProviderView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ProviderView(provider: PlaceholderData.preview.staticMovie.watchProviders.sorted(on: \.name, by: <).first!)
            ProviderView(provider: PlaceholderData.preview.staticMovie.watchProviders.sorted(on: \.name, by: <).last!)
        }
    }
}
