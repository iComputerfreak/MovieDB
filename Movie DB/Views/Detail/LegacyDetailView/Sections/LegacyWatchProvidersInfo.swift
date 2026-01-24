//
//  WatchProvidersInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct LegacyWatchProvidersInfo: View {
    @EnvironmentObject private var mediaObject: Media
    
    var providers: [WatchProvider] {
        mediaObject.watchProviders
            // Only show flatrate and ads providers
            .filter(where: \.type, isNotEqualTo: .buy)
            .filter(where: \.isHidden, isEqualTo: false)
            .removingDuplicates(key: \.id)
            .sorted(on: \.priority, by: <)
    }
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(header: header, footer: footer) {
                VStack {
                    if !providers.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(providers, id: \.id) { provider in
                                    LegacyProviderView(provider: provider, iconSize: 48, showTypeLabel: false)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        // No providers available
                        HStack {
                            Spacer()
                            Text(Strings.Detail.watchProvidersNoneAvailable)
                                .multilineTextAlignment(.center)
                                .font(.callout)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder var header: some View {
        HStack {
            Image(systemName: "tv")
            Text(Strings.Detail.watchProvidersSectionHeader)
        }
    }
    
    @ViewBuilder var footer: some View {
        let attribution = try? AttributedString(markdown: Strings.Detail.watchProvidersAttribution)
        Text(attribution ?? "Powered by JustWatch.com")
    }
}

#Preview {
    List {
        LegacyWatchProvidersInfo()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
        LegacyWatchProvidersInfo()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
        LegacyWatchProvidersInfo()
            .environmentObject(Movie(context: PersistenceController.xcodePreviewContext) as Media)
    }
    .previewEnvironment()
}
