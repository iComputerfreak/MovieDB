//
//  TMDBPoster.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TMDBPoster: View {
    
    let placeholder: Image = Image(systemName: "tv")
    @State private var thumbnail: UIImage?
    
    init(thumbnail: UIImage?) {
        self._thumbnail = State(wrappedValue: thumbnail)
    }
    
    var body: some View {
        // Show either the thumbnail or the placeholder
        Group {
            if (thumbnail != nil) {
                // Thumbnail image
                Image(uiImage: thumbnail!)
                    .poster()
            } else {
                // Placeholder image
                self.placeholder
                    .poster()
                    .padding(5)
            }
        }
    }
}

struct TMDBPoster_Previews: PreviewProvider {
    static var previews: some View {
        TMDBPoster(thumbnail: nil)
    }
}
