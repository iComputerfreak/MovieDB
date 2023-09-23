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
            .removingDuplicates(key: \.id)
            .sorted(on: { provider in
                let typePriority = provider.type?.priority ?? 0
                let providerPriority = provider.priority
                // Multiply the type priority by 1000 to give it more weight
                return typePriority * 1000 + providerPriority
            }, by: >)
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
                                    ProviderView(provider: provider)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 3)
                    } else {
                        // No providers available
                        HStack {
                            Spacer()
                            Text(Strings.Detail.watchProvidersNoneAvailable)
                                .multilineTextAlignment(.center)
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
        WatchProvidersInfo()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
        WatchProvidersInfo()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
        WatchProvidersInfo()
            .environmentObject(Movie(context: PersistenceController.previewContext) as Media)
    }
    .previewEnvironment()
}
