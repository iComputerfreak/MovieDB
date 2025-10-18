//
//  TrailerView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TrailerView: View {
    @EnvironmentObject private var trailer: Video
    
    var body: some View {
        if let videoURL = trailer.videoURL {
            Link(destination: videoURL) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.calloutBackground)
                    VStack {
                        Text(trailer.name)
                            .font(.caption)
                            .lineLimit(2, reservesSpace: true)
                            .frame(width: 140)
                            .padding(4)
                        Spacer()
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                            .padding(8)
                        Spacer()
                    }
                }
            }
        } else {
            EmptyView()
                .onAppear {
                    // We should never arrive here. Videos with missing URLs are filtered out in the super view
                    assertionFailure("Trying to present a trailer with an invalid URL.")
                }
        }
    }
}

#Preview {
    TrailerView()
        .previewEnvironment()
        .environmentObject(PlaceholderData.preview.staticMovie.videos.first(where: \.type, equals: "Trailer")!)
}
