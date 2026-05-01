// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import UIKit

enum LoadableImageSource {
    case image(UIImage?)
    case url(URL?)
}

struct LoadableImageView: View {
    let source: LoadableImageSource
    let contentMode: ContentMode

    init(source: LoadableImageSource, contentMode: ContentMode = .fill) {
        self.source = source
        self.contentMode = contentMode
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var content: some View {
        switch source {
        case let .image(image):
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                PosterPlaceholderView()
            }

        case let .url(url):
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()

                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)

                    case .failure:
                        PosterPlaceholderView()

                    @unknown default:
                        PosterPlaceholderView()
                    }
                }
            } else {
                PosterPlaceholderView()
            }
        }
    }
}

#Preview("Image") {
    LoadableImageView(source: .image(.tmDbLogo), contentMode: .fit)
        .padding()
        .background(.green)
        .previewEnvironment()
}

#Preview("Placeholder") {
    LoadableImageView(source: .image(nil))
        .padding()
        .background(.green)
        .previewEnvironment()
}
