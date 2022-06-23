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
                Section(
                    header: HStack {
                        Image(systemName: "tv")
                        Text(Strings.Detail.watchProvidersSectionHeader)
                    }
                ) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(providers, id: \.id) { provider in
                                ProviderView(provider: provider)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 3)
                    let attribution = try? AttributedString(markdown: Strings.Detail.watchProvidersAttribution)
                    Text(attribution ?? "Powered by JustWatch.com")
                        .font(.footnote)
                }
            }
        }
    }
}

// swiftlint:disable:next file_types_order
struct ProviderView: View {
    let provider: WatchProvider
    
    var body: some View {
        VStack {
            AsyncImage(url: Utils.getTMDBImageURL(path: provider.imagePath!, size: nil)) { image in
                image
                    .resizable()
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .shadow(radius: 1, y: 1.5)
            .padding(2)
            
            Text(provider.type.localized)
                .font(.caption)
        }
    }
}

struct WatchProvidersInfo_Previews: PreviewProvider {
    static var previews: some View {
        List {
            WatchProvidersInfo()
                .environmentObject(PlaceholderData.movie as Media)
        }
    }
}
