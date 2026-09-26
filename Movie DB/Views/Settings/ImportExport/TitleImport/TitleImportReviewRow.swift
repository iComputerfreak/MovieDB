// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct TitleImportReviewRow: View {
    let item: TitleImportReviewItem
    let setIncluded: (Bool) -> Void
    var selectionColor: Color {
        item.isIncluded ? .green : .red
    }
    var selectionIcon: Image {
        if item.inclusionLocked {
            Image(systemName: item.isIncluded ? "checkmark.circle.fill" : "xmark.circle.fill")
        } else {
            Image(systemName: item.isIncluded ? "checkmark.circle" : "circle")
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            checkbox
            VStack(alignment: .leading) {
                // Quote view
                quoteView

                Divider()

                HStack(alignment: .center, spacing: 12) {
                    poster
                        .frame(maxHeight: .infinity, alignment: .top)
                    VStack(alignment: .leading, spacing: 6) {
                        if let candidate = item.candidate {
                            Text(candidate.title)
                                .font(.headline)
                                .lineLimit(2)
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
                    }
                }
            }
        }
        .listRowBackground(selectionColor.opacity(0.1))
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var checkbox: some View {
        Button {
            setIncluded(!item.isIncluded)
        } label: {
            selectionIcon
        }
        .font(.title3)
        .foregroundStyle(selectionColor)
        .contentTransition(.symbolEffect(.automatic))
        .disabled(item.inclusionLocked)
    }

    @ViewBuilder
    private var quoteView: some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(.gray)
                .frame(width: 2)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.source.title)
                    .bold()
                HStack {
                    if let mediaType = item.source.mediaType {
                        MediaTypeCapsule(mediaType: mediaType)
                    }
                    if let year = item.source.year {
                        CapsuleLabelView(text: year.description)
                    }
                }
            }
            .foregroundStyle(.gray)
        }
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

#Preview {
    @Previewable @State var items: [TitleImportReviewItem] = [
        .init(
            id: 0,
            source: .init(
                id: 0,
                title: "Source Title",
                year: 1234,
                directors: [],
                runtimeMinutes: 119,
                mediaType: .movie
            ),
            candidate: .init(
                identity: .init(type: .movie, tmdbID: 603),
                title: "Candidate Title",
                originalTitle: "Original Title",
                year: 2345,
                imagePath: nil,
                popularity: 0,
                alternativeTitles: [],
                directors: []
            ),
            status: .ambiguous,
            reason: "Reason",
            evidence: .init(titleMatch: true),
            isIncluded: true
        ),
        .init(
            id: 1,
            source: .init(
                id: 1,
                title: "Source Title 2",
                year: 2012,
                directors: [],
                runtimeMinutes: 119,
                mediaType: .movie
            ),
            candidate: .init(
                identity: .init(type: .movie, tmdbID: 603),
                title: "Candidate Title 2",
                originalTitle: "Original Title",
                year: 2012,
                imagePath: nil,
                popularity: 0,
                alternativeTitles: [],
                directors: []
            ),
            status: .duplicate,
            reason: "Already included.",
            evidence: .init(titleMatch: true),
            isIncluded: false
        )
    ]

    List {
        ForEach(Array(items.enumerated()), id: \.element.id) { (index, item) in
            TitleImportReviewRow(
                item: item,
                setIncluded: { items[index].isIncluded = $0 }
            )
        }
    }
}
