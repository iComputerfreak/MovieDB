// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

@available(iOS 26.0, *)
struct ParallaxHeaderContentView<Background: View, Header: View, Content: View>: View {
    private enum GeometryReadID {
        case scrollOffset
    }

    private let imageHeight: CGFloat
    private let background: Background
    private let header: Header
    private let content: Content

    @State private var scrollOffset: CGFloat = 0

    private let scrollCoordinateSpaceName: String = "scroll"
    private let backdropGradient: LinearGradient = .init(
        stops: [
            .init(color: .black, location: 0),
            .init(color: .clear, location: 0.5),
        ],
        startPoint: .bottom,
        endPoint: .top
    )

    init(
        imageHeight: CGFloat = 450,
        @ViewBuilder background: () -> Background,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.imageHeight = imageHeight
        self.background = background()
        self.header = header()
        self.content = content()
    }

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                // MARK: Layer 0: Scroll offset measuring
                Color.clear
                    .frame(height: 0)
                    .readGeometryValue(
                        id: GeometryReadID.scrollOffset,
                        into: $scrollOffset,
                        transform: { -$0.frame(in: .named(scrollCoordinateSpaceName)).minY },
                        shouldUpdate: { _, _ in true }
                    )

                // MARK: Layer 1: Background
                backgroundView
                    .overlay {
                        // Cover the part of the image below the header with the background color to prevent it showing below the content
                        Color(UIColor.systemBackground)
                            .offset(y: imageHeight)
                    }

                // MARK: Layer 2: Header Background
                backgroundView
                    .blur(radius: 30)
                    .mask(alignment: .top) {
                        backdropGradient
                            .frame(height: imageHeight)
                    }

                // MARK: Layer 3: Content
                content
                    .padding(.top, imageHeight)
                    .frame(maxWidth: .infinity)

                // MARK: Layer 4: Header
                header
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    // Put content at the bottom border of the header window
                    .frame(height: imageHeight, alignment: .bottom)
                    .background(backdropGradient)
            }
        }
        .coordinateSpace(name: scrollCoordinateSpaceName)
        .ignoresSafeArea(edges: .top)
    }

    private var backgroundView: some View {
        background
        // Keep background fixed in place (negate scrolling)
        // min(imageHeight, ...) lets the image scroll once it's not visible anymore.
        // Without the min(), we would see the image once we scrolled all the way to the bottom
            .offset(y: min(imageHeight, scrollOffset))
    }
}

@available(iOS 26.0, *)
#Preview {
    NavigationStack {
        ParallaxHeaderContentView {
            LinearGradient(colors: [.orange, .purple], startPoint: .top, endPoint: .bottom)
        } header: {
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "Parallax Header")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(verbatim: "Reusable shell preview")
                    .foregroundStyle(.secondary)
            }
        } content: {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<8, id: \.self) { index in
                    GroupBox {
                        Text(verbatim: "Section \(index + 1)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.background)
        }
        .scrollEdgeEffectHidden(for: .top)
        .navigationTitle("")
    }
}
