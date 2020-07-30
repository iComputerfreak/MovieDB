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
            if rating.integerRepresentation < 9 {
                ForEach(Array(0..<(10 - rating.integerRepresentation) / 2), id: \.self) { _ in
                    Image(systemName: "star")
                }
            }
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView(rating: .constant(.twoAndAHalfStars))
    }
}

enum StarRating: Int, Strideable, Codable {
    
    typealias Stride = Int
    
    case noRating
    case oneStar
    case oneAndAHalfStars
    case twoStars
    case twoAndAHalfStars
    case threeStars
    case threeAndAHalfStars
    case fourStars
    case fourAndAHalfStars
    case fiveStars
    
    init?(integerRepresentation: Int) {
        if integerRepresentation == 0 {
            self = .noRating
        }
        if let r = StarRating(rawValue: integerRepresentation - 1) {
            self = r
        } else {
            return nil
        }
    }
    
    /// The integer value of the rating (amount of half stars)
    var integerRepresentation: Int {
        // Shift all values except 0 (no rating) by 1 to compensate the lack of 0.5 stars
        return self == .noRating ? 0 : rawValue + 1
    }
    
    /// The amount of full stars as a string with an optional fraction digit
    var starAmount: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: Double(integerRepresentation) / 2)!
    }
    
    func advanced(by n: Int) -> StarRating {
        return StarRating(rawValue: self.rawValue + n)!
    }
    
    func distance(to other: StarRating) -> Int {
        return other.rawValue - self.rawValue
    }
    
}
