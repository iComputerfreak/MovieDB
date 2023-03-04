//
//  FilterInformationSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterInformationSection: View {
    @EnvironmentObject var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    private var mediaTypeProxy: Binding<String> {
        .init(get: {
            self.filterSetting.mediaType?.rawValue ?? FilterView.nilString
        }, set: { type in
            self.filterSetting.mediaType = type == FilterView.nilString ? nil : MediaType(rawValue: type)
        })
    }
    
    var body: some View {
        Section(header: Text(Strings.Library.Filter.basicInfoSectionHeader)) {
            // MARK: - Media Type
            Picker(Strings.Library.Filter.mediaTypeLabel, selection: mediaTypeProxy) {
                Text(Strings.Library.Filter.valueAny)
                    .tag(FilterView.nilString)
                Text(Strings.movie)
                    .tag(MediaType.movie.rawValue)
                Text(Strings.show)
                    .tag(MediaType.show.rawValue)
                
                    .navigationTitle(Strings.Library.Filter.mediaTypeNavBarTitle)
            }
            // MARK: - Genres
            let genresProxy = Binding<[Genre]> {
                Array(filterSetting.genres).sorted(by: \.name)
            } set: { newValue in
                // We need to move the Genres into the filterSetting context first
                // TODO: Implement. Maybe use this:
//                newValue.map(\.objectID).map { self.managedObjectContext.object(with: $0) }
                filterSetting.genres = Set(newValue)
            }
            FilterMultiPicker(
                selection: genresProxy,
                label: { Text($0.name) },
                values: Utils.allGenres(context: self.managedObjectContext),
                title: Text(Strings.Library.Filter.genresLabel)
            )
            // MARK: - Rating
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
            // MARK: - Year
            NavigationLink {
                RangeEditingView(
                    title: Text(Strings.Library.Filter.yearLabel),
                    bounds: Utils.yearBounds(context: managedObjectContext),
                    setting: $filterSetting.year,
                    style: .stepper
                )
            } label: {
                HStack {
                    Text(Strings.Library.Filter.yearLabel)
                    Spacer()
                    if self.filterSetting.year == nil {
                        Text(Strings.Library.Filter.valueAny)
                            .foregroundColor(.secondary)
                    } else if self.filterSetting.year!.count == 1 {
                        // Lower and upper bound are the same
                        Text(Strings.Library.Filter.yearValueLabel(self.filterSetting.year!.lowerBound))
                            .foregroundColor(.secondary)
                    } else {
                        let from = self.filterSetting.year!.lowerBound
                        let to = self.filterSetting.year!.upperBound
                        Text(Strings.Library.Filter.yearValueRangeLabel(from, to))
                            .foregroundColor(.secondary)
                    }
                }
            }
            // MARK: - Media Status
            FilterMultiPicker(
                selection: $filterSetting.statuses,
                label: { Text($0.rawValue) },
                values: MediaStatus.allCases.sorted(by: \.rawValue),
                title: Text(Strings.Library.Filter.mediaStatusLabel)
            )
        }
    }
}

struct FilterInformationSection_Previews: PreviewProvider {
    static var previews: some View {
        FilterInformationSection()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
