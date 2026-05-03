// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

@available(iOS 26.0, *)
struct ParallaxHeaderContentView<Background: View, Header: View, Content: View>: View {
    private let imageHeight: CGFloat
    private let background: Background
    private let header: Header
    private let content: Content

    @State private var headerHeight: CGFloat = 0
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
                // MARK: Layer 1: Background
                background
                    // Keep background fixed in place (negate scrolling)
                    .offset(y: scrollOffset)
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetKey.self,
                                    value: -proxy.frame(in: .named(scrollCoordinateSpaceName)).minY
                                )
                        }
                    }
                    .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset in
                        print("Scroll offset: \(scrollOffset)")
                        self.scrollOffset = scrollOffset
                    }

                // MARK: Layer 2: Header Background
                background
                // Make the background image NOT scroll with the content
                    .offset(y: scrollOffset)
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
                    .readHeight(into: $headerHeight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    // Put content at the bottom border of the header window
                    .frame(height: imageHeight, alignment: .bottom)
                    .background(alignment: .top) {
                        backdropGradient
                            .frame(height: imageHeight)
                    }
            }
        }
        .coordinateSpace(name: scrollCoordinateSpaceName)
        .ignoresSafeArea(edges: .top)
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
