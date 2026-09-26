// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportReviewRow: View {
    let item: TitleImportReviewItem
    let setIncluded: (Bool) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            poster
            VStack(alignment: .leading, spacing: 6) {
                Text(item.source.title)
                    .font(.headline)
                    .lineLimit(2)
                if let candidate = item.candidate {
                    Text(candidate.title)
                        .font(.subheadline)
                    HStack {
                        MediaTypeCapsule(mediaType: candidate.identity.type)
                        if let year = candidate.year {
                            CapsuleLabelView(text: year.description)
                        }
                    }
                    .font(.caption)
                }
                TitleImportStatusLabel(status: item.status)
                Text(item.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !item.inclusionLocked {
                    Toggle(
                        Strings.TitleImport.Review.include,
                        isOn: Binding(get: { item.isIncluded }, set: setIncluded)
                    )
                    .font(.subheadline)
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var poster: some View {
        if let imagePath = item.candidate?.imagePath,
           let url = Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.thumbnailTMDBSize) {
            LoadableImageView(source: .url(url))
                .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height)
                .thumbnailStyle()
        } else {
            Image(systemName: "film")
                .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height)
                .background(.quaternary, in: .rect(cornerRadius: 6))
        }
    }
}
