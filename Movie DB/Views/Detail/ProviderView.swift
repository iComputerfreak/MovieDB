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
            .frame(width: 50, height: 50)
            .padding(2)
            
            Text(provider.type?.localized ?? "")
                .font(.caption)
        }
    }
    
    func placeholderView(for provider: WatchProvider) -> some View {
        AutoInvertingColor(whiteValue: 0.9, darkSchemeOffset: -0.1)
            .cornerRadius(10)
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
        ProviderView(provider: PlaceholderData.movie.watchProviders.sorted(on: \.name, by: <).first!)
    }
}
