//
//  StarRating.swift
//  Movie DB
//
//  Created by Jonas Frey on 15.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

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
    var integerRepresentation: Int { rawValue }
    
    /// The amount of stars as a double value
    var doubleRepresentation: Double { Double(integerRepresentation) / 2 }
    
    /// The amount of full stars as a string with an optional fraction digit
    var starAmount: String {
        doubleRepresentation.formatted(.number.precision(.fractionLength(0...1)))
    }
    
    init?(integerRepresentation: Int) {
        guard let rating = StarRating(rawValue: integerRepresentation) else {
            return nil
        }
        self = rating
    }
    
    public func advanced(by n: Int) -> StarRating {
        StarRating(rawValue: self.rawValue + n)!
    }
    
    public func distance(to other: StarRating) -> Int {
        other.rawValue - self.rawValue
    }
}
