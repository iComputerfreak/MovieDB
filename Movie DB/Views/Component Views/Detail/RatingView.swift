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
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        // Valid ratings are 0 to 10 stars (0 to 5 stars)
        HStack {
            self.stars(rating)
                .padding(.vertical, 5)
                .foregroundColor(Color.yellow)
            if editMode?.wrappedValue.isEditing ?? false {
                Stepper("", value: $rating, in: StarRating.noRating...StarRating.fiveStars)
            }
        }
    }
    
    private func stars(_ rating: StarRating) -> some View {
        return HStack {
            ForEach(Array(0..<(rating.integerRepresentation / 2)), id: \.self) { _ in
                Image(systemName: "star.fill")
            }
            if rating.integerRepresentation % 2 == 1 {
                Image(systemName: "star.lefthalf.fill")
            }
            // Only if there is at least one empty star
            if rating.integerRepresentation < StarRating.fourAndAHalfStars.integerRepresentation {
                ForEach(Array(0..<(10 - rating.integerRepresentation) / 2), id: \.self) { _ in
                    Image(systemName: "star")
                }
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

public enum StarRating: Int, Strideable, Codable {
    
    case noRating = 0
    case halfStar
    case oneStar
    case oneAndAHalfStars
    case twoStars
    case twoAndAHalfStars
    case threeStars
    case threeAndAHalfStars
    case fourStars
    case fourAndAHalfStars
    case fiveStars
    
    public typealias Stride = Int
    
    /// The integer value of the rating (amount of half stars)
    var integerRepresentation: Int {
        return rawValue
    }
    
    /// The amount of full stars as a string with an optional fraction digit
    var starAmount: String {
        let formatter = NumberFormatter()
        // Set the locale to the correct fraction symbol
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: Double(integerRepresentation) / 2)!
    }
    
    init?(integerRepresentation: Int) {
        guard let rating = StarRating(rawValue: integerRepresentation) else {
            return nil
        }
        self = rating
    }
    
    public func advanced(by n: Int) -> StarRating {
        return StarRating(rawValue: self.rawValue + n)!
    }
    
    public func distance(to other: StarRating) -> Int {
        return other.rawValue - self.rawValue
    }
}
