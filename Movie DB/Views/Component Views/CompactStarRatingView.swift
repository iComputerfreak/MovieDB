//
//  CompactStarRatingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 18.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct CompactStarRatingView: View {
    let rating: StarRating
    
    var body: some View {
        StarRatingView(rating: rating)
            .foregroundColor(.yellow)
            .font(.caption)
    }
}

#Preview {
    ForEach(StarRating.allCases, id: \.rawValue) { rating in
        CompactStarRatingView(rating: rating)
    }
}
