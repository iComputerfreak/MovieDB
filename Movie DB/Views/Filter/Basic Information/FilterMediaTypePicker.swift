//
//  FilterMediaTypePicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterMediaTypePicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    
    private var mediaTypeProxy: Binding<String> {
        .init(get: {
            self.filterSetting.mediaType?.rawValue ?? FilterView.nilString
        }, set: { type in
            self.filterSetting.mediaType = type == FilterView.nilString ? nil : MediaType(rawValue: type)
        })
    }
    
    var body: some View {
        Picker(Strings.Library.Filter.mediaTypeLabel, selection: mediaTypeProxy) {
            Text(Strings.Library.Filter.valueAny)
                .tag(FilterView.nilString)
            Text(Strings.movie)
                .tag(MediaType.movie.rawValue)
            Text(Strings.show)
                .tag(MediaType.show.rawValue)
            
                .navigationTitle(Strings.Library.Filter.mediaTypeNavBarTitle)
        }
    }
}

struct FilterMediaTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        FilterMediaTypePicker()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
