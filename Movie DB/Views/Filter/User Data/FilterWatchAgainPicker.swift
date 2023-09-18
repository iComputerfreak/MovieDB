//
//  FilterWatchAgainPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterWatchAgainPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    
    private var watchAgainProxy: Binding<String> {
        .init(get: {
            self.filterSetting.watchAgain?.description ?? FilterView.nilString
        }, set: { bool in
            self.filterSetting.watchAgain = bool == FilterView.nilString ? nil : Bool(bool)
        })
    }
    
    var body: some View {
        Picker(Strings.Library.Filter.watchAgainLabel, selection: watchAgainProxy) {
            Text(Strings.Library.Filter.valueAny)
                .tag(FilterView.nilString)
            Text(Strings.Generic.pickerValueYes)
                .tag(true.description)
            Text(Strings.Generic.pickerValueNo)
                .tag(false.description)
            
                .navigationTitle(Strings.Library.Filter.watchAgainNavBarTitle)
        }
    }
}

#Preview {
    FilterWatchAgainPicker()
        .previewEnvironment()
}
