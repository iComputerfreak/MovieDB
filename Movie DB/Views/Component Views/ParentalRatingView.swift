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
        CapsuleLabelView(text: rating.label, color: rating.color)
    }
}

struct ParentalRatingView_Preview: PreviewProvider {
    static let context = PersistenceController.previewContext
    
    static var previews: some View {
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
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
