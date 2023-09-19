//
//  MediaTypeCapsule.swift
//  Movie DB
//
//  Created by Jonas Frey on 19.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaTypeCapsule: View {
    let mediaType: MediaType
    
    var body: some View {
        switch mediaType {
        case .movie:
            CapsuleLabelView(text: Strings.Library.movieSymbolName)
        case .show:
            CapsuleLabelView(text: Strings.Library.showSymbolName)
        }
    }
}

#Preview {
    VStack {
        MediaTypeCapsule(mediaType: .movie)
        MediaTypeCapsule(mediaType: .show)
    }
}
