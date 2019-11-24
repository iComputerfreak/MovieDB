//
//  HeadlineModifier.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

extension View {
    
    /// Adds a headline view above this view with the given title
    /// - Parameter headline: The title to use for the headline
    func headline(_ headline: String) -> some View {
        return VStack(alignment: .leading, spacing: 0) {
            Text(headline)
                .font(.caption)
                .foregroundColor(.primary)
            self
        }
    }
}
