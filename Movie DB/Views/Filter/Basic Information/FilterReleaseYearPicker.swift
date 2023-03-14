//
//  FilterReleaseYearPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterReleaseYearPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
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
    }
}

struct FilterReleaseYearPicker_Previews: PreviewProvider {
    static var previews: some View {
        FilterReleaseYearPicker()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
