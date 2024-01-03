//
//  PosterDetailView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import JFSwiftUI
import SwiftUI

/// Displays a poster image in fullscreen
struct PosterDetailView: View {
    let imagePath: String?
    
    var url: URL? {
        // swiftlint:disable:next redundant_nil_coalescing
        imagePath.map { Utils.getTMDBImageURL(path: $0, size: nil) } ?? nil
    }
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        } loading: {
            ProgressView()
        } fallback: {
            Image(uiImage: UIImage.posterPlaceholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
    }
}

#Preview {
    PosterDetailView(imagePath: nil)
}
