// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

/// Represents a line-limited text preview that can open the full text in a sheet when it is truncated.
struct TruncatingTextSheet: View {
    let text: String
    let sheetTitle: String
    let lineLimit: Int
    let moreButtonTitle: String

    @State private var fullTextHeight: CGFloat = 0
    @State private var truncatedTextHeight: CGFloat = 0
    @State private var isShowingFullText = false

    init(
        _ text: String,
        sheetTitle: String,
        lineLimit: Int = LongTextView.lineLimit,
        moreButtonTitle: String = Strings.Generic.longTextShowMore
    ) {
        self.text = text
        self.sheetTitle = sheetTitle
        self.lineLimit = lineLimit
        self.moreButtonTitle = moreButtonTitle
    }

    private var isTruncated: Bool {
        fullTextHeight - truncatedTextHeight > 1
    }

    var body: some View {
        if !isTruncated {
            textContent
        } else {
            Group {
                Button {
                    isShowingFullText = true
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        textContent
                        if isTruncated {
                            Text(moreButtonTitle)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .sheet(isPresented: $isShowingFullText) {
                fullTextSheetContent
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    var textContent: some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .lineLimit(lineLimit)
            .readHeight(into: $truncatedTextHeight)
            .background {
                Text(text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .readHeight(into: $fullTextHeight)
                    .hidden()
                    .accessibilityHidden(true)
            }
    }

    var fullTextSheetContent: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .foregroundStyle(.blackWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle(sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DismissButton()
                }
            }
        }
    }
}

#Preview {
    TruncatingTextSheet(
        "A very long text that spans multiple lines and should eventually show a button " +
        "that opens the full content in a sheet once the preview becomes truncated " +
        "by the configured line limit.",
        sheetTitle: "Description"
    )
    .padding()
}
