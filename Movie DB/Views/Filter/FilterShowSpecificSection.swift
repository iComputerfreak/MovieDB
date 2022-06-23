//
//  FilterShowSpecificSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterShowSpecificSection: View {
    @ObservedObject var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Section(header: Text(Strings.Library.Filter.showSpecificSectionHeader)) {
            // MARK: - Show Type
            FilterMultiPicker(
                selection: $filterSetting.showTypes,
                label: { Text($0.rawValue) },
                values: ShowType.allCases.sorted(by: \.rawValue),
                title: Text(Strings.Library.Filter.showTypeLabel)
            )
            // MARK: - Number of Seasons
            NavigationLink {
                RangeEditingView(
                    title: Text(Strings.Library.Filter.seasonsLabel),
                    bounds: Utils.numberOfSeasonsBounds(context: managedObjectContext),
                    setting: self.$filterSetting.numberOfSeasons,
                    style: .stepper
                )
            } label: {
                HStack {
                    Text(Strings.Library.Filter.seasonsLabel)
                    Spacer()
                    if self.filterSetting.numberOfSeasons == nil {
                        Text(Strings.Library.Filter.valueAny)
                            .foregroundColor(.secondary)
                    } else if self.filterSetting.numberOfSeasons!.count == 1 {
                        let value = self.filterSetting.numberOfSeasons!.lowerBound
                        Text(Strings.Library.Filter.seasonsValueLabel(value))
                        .foregroundColor(.secondary)
                    } else {
                        let from = self.filterSetting.numberOfSeasons!.lowerBound
                        let to = self.filterSetting.numberOfSeasons!.upperBound
                        Text(Strings.Library.Filter.seasonsValueRangeLabel(from, to))
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct FilterShowSpecificSection_Previews: PreviewProvider {
    static var previews: some View {
        FilterShowSpecificSection(
            filterSetting: FilterSetting(context: PersistenceController.createDisposableContext())
        )
    }
}
