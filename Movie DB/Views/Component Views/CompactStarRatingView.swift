// Copyright © 2023 Jonas Frey. All rights reserved.

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
