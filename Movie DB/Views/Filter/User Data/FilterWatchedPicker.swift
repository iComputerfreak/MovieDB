//
//  FilterWatchedPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterWatchedPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    
    var body: some View {
        Picker(Strings.Library.Filter.watchedLabel, selection: $filterSetting.watched) {
            Text(Strings.Library.Filter.valueAny)
                .tag(nil as FilterSetting.FilterWatchState?)
            ForEach(FilterSetting.FilterWatchState.allCases, id: \.rawValue) { watchState in
                Text(watchState.localized)
                    .tag(watchState as FilterSetting.FilterWatchState?)
            }
                .navigationTitle(Strings.Library.Filter.watchedNavBarTitle)
        }
    }
}

struct FilterWatchedPicker_Previews: PreviewProvider {
    static var previews: some View {
        FilterWatchedPicker()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
