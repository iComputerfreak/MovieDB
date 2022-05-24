//
//  ViewModifiers.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
    /// Modifies the image to be of a pre-set thumbnail size
    /// - Parameter multiplier: A multiplier value applied to the thumbnail size
    /// - Returns: The image resized to a thumbnail
    func thumbnail(multiplier: CGFloat = 1.0) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: JFLiterals.thumbnailSize.width * multiplier,
                height: JFLiterals.thumbnailSize.height * multiplier,
                alignment: .center
            )
    }
}

extension View {
    /// Adds a headline view above this view with the given title
    /// - Parameter headlineKey: The title to use for the headline
    func headline(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            self
        }
    }
    
    /// Adds a headline view above this view with the given title
    /// - Parameter headline: The title to use for the headline
    func headline(verbatim headline: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(headline)
                .font(.caption)
                .foregroundColor(.primary)
            self
        }
    }
}
