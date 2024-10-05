//
//  ParentalRatingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI
import UIKit

struct ParentalRatingView: View {
    let rating: ParentalRating
    
    var body: some View {
        CapsuleLabelView {
            Text(rating.label)
                .font(.caption)
                .bold()
                .foregroundColor(rating.color)
                .shadow(color: .primary, radius: 0.15, x: 0, y: 0)
                .shadow(color: .primary, radius: 0.15, x: 0, y: 0)
                .shadow(color: .primary, radius: 0.15, x: 0, y: 0)
                .shadow(color: .primary, radius: 0.15, x: 0, y: 0)
        }
    }
}

#Preview() {
    let context = PersistenceController.previewContext
    
    VStack {
        HStack {
            Text(verbatim: "Rating: ")
            ParentalRatingView(rating: .init(
                context: context,
                countryCode: "US",
                label: "R",
                color: UIColor(named: "US-Movie-R")
            ))
        }
        HStack {
            Text(verbatim: "Rating: ")
            ParentalRatingView(rating: .init(
                context: context,
                countryCode: "DE",
                label: "16",
                color: UIColor(named: "AgeSixteen")
            ))
        }
        HStack {
            Text(verbatim: "Rating: ")
            ForEach(PlaceholderData.preview.fskRatings, id: \.label) { rating in
                ParentalRatingView(rating: rating)
            }
        }
    }
}
