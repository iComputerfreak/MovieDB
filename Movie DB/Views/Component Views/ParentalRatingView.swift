//
//  ParentalRatingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ParentalRatingView: View {
    let rating: ParentalRating
    
    var body: some View {
        CapsuleLabelView(text: rating.label, color: rating.color)
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
                ForEach(ParentalRating.fskRatings, id: \.label) { rating in
                    ParentalRatingView(rating: rating)
                }
            }
        }
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
