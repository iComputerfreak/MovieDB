//
//  StarRatingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 18.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct StarRatingView: View {
    let rating: StarRating
    let spacing: CGFloat?
    
    init(rating: StarRating, spacing: CGFloat? = nil) {
        self.rating = rating
        self.spacing = spacing
    }
    
    var fullStars: Int {
        rating.integerRepresentation / 2
    }
    
    var halfStar: Bool {
        rating.integerRepresentation % 2 == 1
    }
    
    var emptyStars: Int {
        5 - fullStars - (halfStar ? 1 : 0)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(0..<fullStars), id: \.self) { _ in
                Image(systemName: "star.fill")
            }
            if halfStar {
                Image(systemName: "star.leadinghalf.filled")
            }
            ForEach(Array(0..<emptyStars), id: \.self) { _ in
                Image(systemName: "star")
            }
        }
        .foregroundColor(.yellow)
    }
}

#Preview {
    List {
        ForEach(StarRating.allCases, id: \.rawValue) { rating in
            StarRatingView(rating: rating)
        }
    }
}
