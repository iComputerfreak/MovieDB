// Copyright © 2022 Jonas Frey. All rights reserved.

import JFSwiftUI
import SwiftUI

/// Displays a poster image in fullscreen
struct LegacyPosterDetailView: View {
    let imagePath: String?
    
    var url: URL? {
        // swiftlint:disable:next redundant_nil_coalescing
        imagePath.map { Utils.getTMDBImageURL(path: $0, size: nil) } ?? nil
    }
    
    var body: some View {
        LoadableImageView(source: .url(url), contentMode: .fit)
            .aspectRatio(JFLiterals.thumbnailSize.width / JFLiterals.thumbnailSize.height, contentMode: .fit)
            .padding()
    }
}

#Preview {
    LegacyPosterDetailView(imagePath: nil)
}
