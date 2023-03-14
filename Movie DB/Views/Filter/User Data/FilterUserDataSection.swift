//
//  FilterUserDataSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterUserDataSection: View {
    @EnvironmentObject var filterSetting: FilterSetting
    
    var body: some View {
        Section(header: Text(Strings.Library.Filter.userDataSectionHeader)) {
            // MARK: - Watched?
            FilterWatchedPicker()
            // MARK: - Watch Again?
            FilterWatchAgainPicker()
            // MARK: - Tags
            FilterTagsPicker()
        }
    }
}

struct FilterUserDataSection_Previews: PreviewProvider {
    static var previews: some View {
        FilterUserDataSection()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
