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
        Section(header: Text(
            "detail.information.header",
            comment: "The section header for the information section in the detail view"
        )) {
            // MARK: - Media Type
            Picker("Media Type", selection: mediaTypeProxy) {
                Text(
                    "library.filter.value.any",
                    // swiftlint:disable:next line_length
                    comment: "A string describing that the value of a specific media property does not matter in regards of filtering the library list and that the property may have 'any' value."
                )
                    .tag(FilterView.nilString)
                Text(
                    "global.strings.movie",
                    comment: "A string describing a type of media"
                )
                    .tag(MediaType.movie.rawValue)
                Text(
                    "global.strings.show",
                    comment: "A string describing a type of media"
                )
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
                        title: Text(
                            "detail.information.personalRating",
                            comment: "The personal rating one assign a media object as a value of 0 to 5 stars"
                        ),
                        bounds: StarRating.noRating...StarRating.fiveStars,
                        setting: $filterSetting.rating,
                        style: .stepper,
                        valueLabel: { RatingView(rating: .constant($0)) }
                    )
            ) {
                HStack {
                    Text(
                        "detail.information.personalRating",
                        comment: "The personal rating one assign a media object as a value of 0 to 5 stars"
                    )
                    Spacer()
                    if self.filterSetting.rating == nil {
                        Text(
                            "library.filter.value.any",
                            // swiftlint:disable:next line_length
                            comment: "A string describing that the value of a specific media property does not matter in regards of filtering the library list and that the property may have 'any' value."
                        )
                            .foregroundColor(.secondary)
                    } else if self.filterSetting.rating!.count == 1 {
                        // Formatting of the double is done in the localization
                        let amount = self.filterSetting.rating!.lowerBound.doubleRepresentation
                        Text(
                            "library.filter.information.label.rating \(amount)",
                            comment: "A star rating from 0 to 5 stars in 0.5 star steps"
                        )
                        .foregroundColor(.secondary)
                    } else {
                        let from = self.filterSetting.rating!.lowerBound.doubleRepresentation
                        let to = self.filterSetting.rating!.upperBound.doubleRepresentation
                        Text(
                            "library.filter.information.label.rating.range \(from) \(to)",
                            comment: "A range of star ratings, both ranging from 0 to 5 stars in 0.5 star steps"
                        )
                        .foregroundColor(.secondary)
                    }
                }
            }
            // MARK: - Year
            NavigationLink(destination: RangeEditingView(
                title: Text(
                    "library.filter.information.label.year",
                    comment: "The label for the picker for selecting the release year in the library filter view"
                ),
                bounds: Utils.yearBounds(context: managedObjectContext),
                setting: $filterSetting.year,
                style: .stepper
            )) {
                HStack {
                    Text(
                        "library.filter.information.label.year",
                        comment: "The label for the picker for selecting the release year in the library filter view"
                    )
                    Spacer()
                    if self.filterSetting.year == nil {
                        Text(
                            "library.filter.value.any",
                            // swiftlint:disable:next line_length
                            comment: "A string describing that the value of a specific media property does not matter in regards of filtering the library list and that the property may have 'any' value."
                        )
                            .foregroundColor(.secondary)
                    } else if self.filterSetting.year!.count == 1 {
                        // Lower and upper bound are the same
                        Text(
                            "library.filter.information.label.year \(self.filterSetting.year!.lowerBound)",
                            comment: "Year label in the filter settings"
                        )
                            .foregroundColor(.secondary)
                    } else {
                        let from = self.filterSetting.year!.lowerBound.description
                        let to = self.filterSetting.year!.upperBound.description
                        Text(
                            "library.filter.information.label.year.range \(from) \(to)",
                            comment: "Year range label in the filter settings"
                        )
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
