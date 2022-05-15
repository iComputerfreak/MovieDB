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
        Section(header: Text("Show specific")) {
            // MARK: - Show Type
            FilterMultiPicker(
                selection: $filterSetting.showTypes,
                label: { $0.rawValue },
                values: ShowType.allCases.sorted(by: \.rawValue),
                titleKey: "Show Type"
            )
            // MARK: - Number of Seasons
            NavigationLink(destination: RangeEditingView(
                title: Text("Seasons"),
                bounds: Utils.numberOfSeasonsBounds(context: managedObjectContext),
                setting: self.$filterSetting.numberOfSeasons,
                style: .stepper
            )) {
                HStack {
                    Text("Seasons")
                    Spacer()
                    if self.filterSetting.numberOfSeasons == nil {
                        Text("Any")
                            .foregroundColor(.secondary)
                    } else if self.filterSetting.numberOfSeasons!.count == 1 {
                        let formatString = NSLocalizedString(
                            "%lld seasons",
                            comment: "Season count in filter"
                        )
                        Text(String.localizedStringWithFormat(
                            formatString,
                            self.filterSetting.numberOfSeasons!.lowerBound
                        ))
                            .foregroundColor(.secondary)
                    } else {
                        let formatString = NSLocalizedString(
                            "%lld to %lld seasons",
                            comment: "Season range in filter"
                        )
                        Text(String.localizedStringWithFormat(
                            formatString,
                            self.filterSetting.numberOfSeasons!.lowerBound,
                            self.filterSetting.numberOfSeasons!.upperBound
                        ))
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
