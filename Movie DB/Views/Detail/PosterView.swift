//
//  PosterView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import JFSwiftUI
import SwiftUI

struct PosterView: View {
    let imagePath: String?
    
    var url: URL? {
        imagePath.map { Utils.getTMDBImageURL(path: $0, size: nil) }
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
            Image(JFLiterals.posterPlaceholderName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
    }
}

struct PosterView_Previews: PreviewProvider {
    static var previews: some View {
        PosterView(imagePath: nil)
    }
}
