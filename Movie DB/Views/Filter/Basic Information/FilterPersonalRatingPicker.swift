//
//  FilterPersonalRatingPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterPersonalRatingPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    
    var body: some View {
        NavigationLink {
            RangeEditingView(
                title: Text(Strings.Library.Filter.ratingLabel),
                bounds: StarRating.noRating...StarRating.fiveStars,
                setting: $filterSetting.rating,
                style: .stepper,
                valueLabel: { RatingView(rating: .constant($0)) }
            )
        } label: {
            HStack {
                Text(Strings.Library.Filter.ratingLabel)
                Spacer()
                if self.filterSetting.rating == nil {
                    Text(Strings.Library.Filter.valueAny)
                        .foregroundColor(.secondary)
                } else if self.filterSetting.rating!.count == 1 {
                    // Formatting of the double is done in the localization
                    let amount = self.filterSetting.rating!.lowerBound.doubleRepresentation
                    Text(Strings.Library.Filter.ratingValueLabel(amount))
                        .foregroundColor(.secondary)
                } else {
                    let from = self.filterSetting.rating!.lowerBound.doubleRepresentation
                    let to = self.filterSetting.rating!.upperBound.doubleRepresentation
                    Text(Strings.Library.Filter.ratingValueRangeLabel(from, to))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct FilterRatingPicker_Previews: PreviewProvider {
    static var previews: some View {
        FilterPersonalRatingPicker()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
