//
//  RatingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Provides a view that displays an editable star rating
struct RatingView: View {
    @Binding var rating: StarRating
    @Environment(\.isEditing) private var isEditing
    
    var body: some View {
        // Valid ratings are 0 to 10 stars (0 to 5 stars)
        HStack {
            StarRatingView(rating: rating)
                .padding(.vertical, 5)
                .foregroundColor(Color.yellow)
            if isEditing {
                Stepper("", value: $rating, in: StarRating.noRating...StarRating.fiveStars)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    List {
        ForEach(StarRating.allCases, id: \.rawValue) { rating in
            RatingView(rating: .constant(rating))
        }
    }
    .padding()
}
