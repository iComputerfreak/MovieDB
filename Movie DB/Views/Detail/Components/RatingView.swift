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

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RatingView(rating: .constant(.noRating))
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("No Rating")
        
        Group {
            RatingView(rating: .constant(.halfStar))
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Half Star")
        
        Group {
            RatingView(rating: .constant(.oneStar))
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("One Star")
        
        Group {
            RatingView(rating: .constant(.twoAndAHalfStars))
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Two and a Half Stars")
        
        Group {
            RatingView(rating: .constant(.fourAndAHalfStars))
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Four and a Half Stars")
        
        Group {
            RatingView(rating: .constant(.fiveStars))
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Five Stars")
    }
}
