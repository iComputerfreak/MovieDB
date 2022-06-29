//
//  ParentalRating.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

// swiftlint:disable file_types_order

struct ParentalRatingView: View {
    let rating: ParentalRating
    
    var body: some View {
        Text(rating.label)
            .font(.caption2)
            .padding(.horizontal, 1.5)
            .padding(.vertical, 0.5)
            .background(
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(rating.color ?? .primary, lineWidth: 1.5)
            )
            .foregroundColor(rating.color ?? .primary)
    }
}

struct ParentalRatingView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                Text(verbatim: "Rating: ")
                ParentalRatingView(rating: .init("R", color: .red))
            }
            HStack {
                Text(verbatim: "Rating: ")
                ParentalRatingView(rating: .init("PG-13", color: .green))
            }
            HStack {
                Text(verbatim: "Rating: ")
                ParentalRatingView(rating: .fskAgeSixteen)
            }
        }
        .previewLayout(.fixed(width: 200, height: 100))
    }
}

public struct ParentalRating {
    var color: Color?
    var label: String
    
    var symbol: some View {
        ParentalRatingView(rating: self)
    }
    
    init(_ label: String, color: Color? = nil) {
        self.label = label
        self.color = color
    }
}

extension ParentalRating {
    static let fskRatings = [fskNoRestriction, fskAgeSix, fskAgeTwelve, fskAgeSixteen, fskAgeEighteen]
    static let fskNoRestriction: Self = .init("0", color: .init("NoRestriction"))
    static let fskAgeSix: Self = .init("6", color: .init("AgeSix"))
    static let fskAgeTwelve: Self = .init("12", color: .init("AgeTwelve"))
    static let fskAgeSixteen: Self = .init("16", color: .init("AgeSixteen"))
    static let fskAgeEighteen: Self = .init("18", color: .init("AgeEighteen"))
}
