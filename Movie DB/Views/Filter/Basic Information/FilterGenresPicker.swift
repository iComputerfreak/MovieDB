//
//  FilterGenresPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterGenresPicker: View {
    @EnvironmentObject private var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var genresProxy: Binding<[Genre]> {
        .init {
            Array(filterSetting.genres).sorted(on: \.name, by: <)
        } set: { newValue in
            // We need to move the Genres into the filterSetting context first
            // TODO: Implement. Maybe use this:
            //                newValue.map(\.objectID).map { self.managedObjectContext.object(with: $0) }
            filterSetting.genres = Set(newValue)
        }
    }
    
    var body: some View {
        FilterMultiPicker(
            selection: genresProxy,
            label: { Text($0.name) },
            values: Utils.allGenres(context: self.managedObjectContext),
            title: Text(Strings.Library.Filter.genresLabel)
        )
    }
}

struct FilterGenresPicker_Previews: PreviewProvider {
    static var previews: some View {
        FilterGenresPicker()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
