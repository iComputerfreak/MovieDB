//
//  ShareMediaButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ShareMediaButton: View {
    @EnvironmentObject private var mediaObject: Media
    
    var shareURL: URL? {
        URL(string: "https://movieorganizer.de/\(mediaObject.type.rawValue)/\(mediaObject.tmdbID)")
    }
    
    var body: some View {
        if let url = shareURL {
            ShareLink(item: url, message: Text(mediaObject.title))
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ShareMediaButton()
}
