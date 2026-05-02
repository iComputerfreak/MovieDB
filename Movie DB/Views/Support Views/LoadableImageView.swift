// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import UIKit

enum LoadableImageSource {
    case image(UIImage?)
    case url(URL?)
    case loader(id: AnyHashable, load: @Sendable () async throws -> UIImage?)
}

struct LoadableImageView: View {
    let source: LoadableImageSource
    let contentMode: ContentMode
    let alignment: Alignment

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    init(source: LoadableImageSource, contentMode: ContentMode = .fill, alignment: Alignment = .center) {
        self.source = source
        self.contentMode = contentMode
        self.alignment = alignment
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .task(id: loaderID) {
                await loadImageIfNeeded()
            }
    }

    private var loaderID: AnyHashable? {
        if case let .loader(id, _) = source {
            id
        } else {
            nil
        }
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
                emptyState
            }

        case let .url(url):
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        loadingState

                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)

                    case .failure:
                        errorState

                    @unknown default:
                        emptyState
                    }
                }
            } else {
                emptyState
            }

        case .loader:
            if isLoading {
                loadingState
            } else if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                // TODO: This is technically also the error state
                emptyState
            }
        }
    }

    @MainActor
    private func loadImageIfNeeded() async {
        guard case let .loader(_, load) = source else { return }

        isLoading = true
        loadedImage = nil

        do {
            loadedImage = try await load()
        } catch {
            loadedImage = nil
        }

        isLoading = false
    }

    private var loadingState: some View {
        ProgressView()
    }

    private var errorState: some View {
        PosterPlaceholderView()
    }

    private var emptyState: some View {
        PosterPlaceholderView()
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
