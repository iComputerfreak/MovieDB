//
//  FilterShowSpecificSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterShowSpecificSection: View {
    @Binding var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Section(header: Text(
            "library.filter.showSpecific.header",
            comment: "The heading in the library filter view for the properties that are specific to tv shows"
        )) {
            // MARK: - Show Type
            FilterMultiPicker(
                selection: $filterSetting.showTypes,
                label: { $0.rawValue },
                values: ShowType.allCases.sorted(by: \.rawValue),
                title: Text(
                    "library.filter.showSpecific.label.showType",
                    comment: "The label for the show type picker in the library's filter view"
                )
            )
            // MARK: - Number of Seasons
            NavigationLink(destination: RangeEditingView(
                title: Text(
                    "library.filter.showSpecific.label.seasons",
                    // swiftlint:disable:next line_length
                    comment: "The label for the picker in the filter view that lets the user choose the range of number of seasons to filter by"
                ),
                bounds: Utils.numberOfSeasonsBounds(context: managedObjectContext),
                setting: self.$filterSetting.numberOfSeasons,
                style: .stepper
            )) {
                HStack {
                    Text(
                        "library.filter.showSpecific.label.seasons",
                        // swiftlint:disable:next line_length
                        comment: "The label for the picker in the filter view that lets the user choose the range of number of seasons to filter by"
                    )
                    Spacer()
                    if self.filterSetting.numberOfSeasons == nil {
                        Text(
                            "library.filter.value.any",
                            // swiftlint:disable:next line_length
                            comment: "A string describing that the value of a specific media property does not matter in regards of filtering the library list and that the property may have 'any' value."
                        )
                            .foregroundColor(.secondary)
                    } else if self.filterSetting.numberOfSeasons!.count == 1 {
                        let value = self.filterSetting.numberOfSeasons!.lowerBound
                        Text(
                            "library.filter.showSpecific.label.seasonCount \(value)",
                            comment: "The season count label in the filter settings"
                        )
                        .foregroundColor(.secondary)
                    } else {
                        let from = self.filterSetting.numberOfSeasons!.lowerBound
                        let to = self.filterSetting.numberOfSeasons!.upperBound
                        Text(
                            "library.filter.showSpecific.label.seasonCount.range \(from) \(to)",
                            comment: "The label for the range of season counts in the filter settings"
                        )
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct FilterShowSpecificSection_Previews: PreviewProvider {
    static var previews: some View {
        FilterShowSpecificSection(filterSetting: .constant(FilterSetting()))
    }
}
