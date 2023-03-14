//
//  FilterNumberOfSeasonsPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterNumberOfSeasonsPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
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

struct FilterNumberOfSeasonsPicker_Previews: PreviewProvider {
    static var previews: some View {
        FilterNumberOfSeasonsPicker()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
