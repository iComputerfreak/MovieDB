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
        Text(rating.label)
            .font(.caption)
            .bold()
            .padding(.horizontal, 3)
            .padding(.vertical, 1.5)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(rating.color ?? .primary, lineWidth: 2)
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
                ForEach(ParentalRating.fskRatings, id: \.label) { rating in
                    ParentalRatingView(rating: rating)
                }
            }
        }
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
