//
//  FilterInformationSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterInformationSection: View {
    @Binding var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    private var mediaTypeProxy: Binding<String> {
        .init(get: {
            self.filterSetting.mediaType?.rawValue ?? FilterView.nilString
        }, set: { type in
            self.filterSetting.mediaType = type == FilterView.nilString ? nil : MediaType(rawValue: type)
        })
    }
    
    var body: some View {
        Section(header: Text("Information")) {
            // MARK: - Media Type
            Picker("Media Type", selection: mediaTypeProxy) {
                Text("Any")
                    .tag(FilterView.nilString)
                Text("Movie")
                    .tag(MediaType.movie.rawValue)
                Text("TV Show")
                    .tag(MediaType.show.rawValue)
                
                    .navigationTitle("Media Type")
            }
            // MARK: - Genres
            let genresProxy = Binding<[Genre]> {
                Array(filterSetting.genres).sorted(by: \.name)
            } set: { newValue in
                filterSetting.genres = Set(newValue)
            }
            FilterMultiPicker(
                selection: genresProxy,
                label: { $0.name },
                values: Utils.allGenres(context: self.managedObjectContext),
                titleKey: "Genres"
            )
            // MARK: - Rating
            NavigationLink(
                destination:
                    RangeEditingView(
                        title: Text("Rating"),
                        bounds: StarRating.noRating...StarRating.fiveStars,
                        setting: $filterSetting.rating,
                        style: .stepper,
                        valueLabel: { RatingView(rating: .constant($0)) }
                    )
            ) {
                HStack {
                    Text("Rating")
                    Spacer()
                    if self.filterSetting.rating == nil {
                        Text("Any")
                            .foregroundColor(.secondary)
                    } else if self.filterSetting.rating!.count == 1 {
                        // Formatting of the double is done in the localization
                        let amount = self.filterSetting.rating!.lowerBound.doubleRepresentation
                        Text(
                            "\(amount) Stars",
                            comment: "A star rating from 0 to 5 stars in 0.5 star steps"
                        )
                        .foregroundColor(.secondary)
                    } else {
                        let from = self.filterSetting.rating!.lowerBound.doubleRepresentation
                        let to = self.filterSetting.rating!.upperBound.doubleRepresentation
                        Text(
                            "\(from) to \(to) Stars",
                            comment: "A range of star ratings, both ranging from 0 to 5 stars in 0.5 star steps"
                        )
                        .foregroundColor(.secondary)
                    }
                }
            }
            // MARK: - Year
            NavigationLink(destination: RangeEditingView(
                title: Text("Year"),
                bounds: Utils.yearBounds(context: managedObjectContext),
                setting: $filterSetting.year,
                style: .stepper
            )) {
                HStack {
                    Text("Year")
                    Spacer()
                    if self.filterSetting.year == nil {
                        Text("Any")
                            .foregroundColor(.secondary)
                    } else if self.filterSetting.year!.count == 1 {
                        // Lower and upper bound are the same
                        Text(self.filterSetting.year!.lowerBound.description)
                            .foregroundColor(.secondary)
                    } else {
                        let from = self.filterSetting.year!.lowerBound.description
                        let to = self.filterSetting.year!.upperBound.description
                        Text("\(from) to \(to)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            // MARK: - Media Status
            FilterMultiPicker(
                selection: $filterSetting.statuses,
                label: { $0.rawValue },
                values: MediaStatus.allCases.sorted(by: \.rawValue),
                titleKey: "Status"
            )
        }
    }
}

struct FilterInformationSection_Previews: PreviewProvider {
    static var previews: some View {
        FilterInformationSection(filterSetting: .constant(FilterSetting()))
    }
}
