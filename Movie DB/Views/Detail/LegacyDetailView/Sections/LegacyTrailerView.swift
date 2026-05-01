//
//  TrailerView.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct LegacyTrailerView: View {
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
        }
    }
}

#Preview {
    LegacyTrailerView()
        .previewEnvironment()
        .environmentObject(PlaceholderData.preview.staticMovie.videos.first(where: \.type, equals: "Trailer")!)
}
