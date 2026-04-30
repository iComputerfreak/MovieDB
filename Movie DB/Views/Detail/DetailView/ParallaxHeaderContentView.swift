//
//  ParallaxHeaderContentView.swift
//  Movie DB
//
//  Created by OpenCode on 30.04.26.
//  Copyright © 2026 Jonas Frey. All rights reserved.
//

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
            .init(color: .clear, location: 1),
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
            VStack(spacing: 0) {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: imageHeight)
                    .overlay(alignment: .bottom) {
                        header
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .padding(.top, 48)
                            .frame(maxWidth: .infinity)
                            .background(backdropGradient)
                            .background {
                                background
                                    .padding(.top, -(imageHeight - headerHeight - scrollOffset))
                                    .blur(radius: 30)
                                    .frame(height: headerHeight, alignment: .top)
                                    .clipped()
                                    .mask(backdropGradient)
                            }
                            .background {
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(key: TitleViewHeightKey.self, value: proxy.size.height)
                                }
                            }
                            .onPreferenceChange(TitleViewHeightKey.self) { headerHeight in
                                self.headerHeight = headerHeight
                            }
                    }

                content
            }
            .frame(maxWidth: .infinity)
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
                self.scrollOffset = scrollOffset
            }
        }
        .background(alignment: .top) {
            background
                .frame(height: imageHeight)
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
