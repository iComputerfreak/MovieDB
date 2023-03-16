//
//  FilterWatchedPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

// TODO: After consolidating MovieWatchState and ShowWatchState, we should update the type in FilterSetting and here
struct FilterWatchedPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    
    private var watchedProxy: Binding<String> {
        .init(get: {
            self.filterSetting.watched?.description ?? FilterView.nilString
        }, set: { bool in
            self.filterSetting.watched = bool == FilterView.nilString ? nil : Bool(bool)
        })
    }
    
    var body: some View {
        Picker(Strings.Library.Filter.watchedLabel, selection: watchedProxy) {
            Text(Strings.Library.Filter.valueAny)
                .tag(FilterView.nilString)
            Text(Strings.Generic.pickerValueYes)
                .tag(true.description)
            Text(Strings.Generic.pickerValueNo)
                .tag(false.description)
            
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
