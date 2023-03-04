//
//  WatchProvidersInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchProvidersInfo: View {
    @EnvironmentObject private var mediaObject: Media
    
    var providers: [WatchProvider] {
        mediaObject.watchProviders
            .filter { $0.type != .buy }
            .sorted(by: [\.type.priority, \.priority])
            .reversed()
    }
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            if !providers.isEmpty {
                Section(header: header, footer: footer) {
                    VStack {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(providers, id: \.id) { provider in
                                    ProviderView(provider: provider)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 3)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var header: some View {
        HStack {
            Image(systemName: "tv")
            Text(Strings.Detail.watchProvidersSectionHeader)
        }
    }
    
    @ViewBuilder
    var footer: some View {
        let attribution = try? AttributedString(markdown: Strings.Detail.watchProvidersAttribution)
        Text(attribution ?? "Powered by JustWatch.com")
    }
}

struct ProviderView: View {
    let provider: WatchProvider
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Group {
                if let imagePath = provider.imagePath {
                    AsyncImage(url: Utils.getTMDBImageURL(path: imagePath, size: nil)) { image in
                        image
                            .resizable()
                            .cornerRadius(10)
                            .shadow(radius: 1, y: 1.5)
                    } placeholder: {
                        placeholderView(for: provider)
                    }
                } else {
                    placeholderView(for: provider)
                }
            }
            .frame(width: 50, height: 50)
            .padding(2)
            
            Text(provider.type.localized)
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

struct WatchProvidersInfo_Previews: PreviewProvider {
    static var previews: some View {
        List {
            WatchProvidersInfo()
                .environmentObject(PlaceholderData.movie as Media)
                .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
