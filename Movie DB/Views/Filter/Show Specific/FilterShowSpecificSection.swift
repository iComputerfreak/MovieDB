//
//  FilterShowSpecificSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterShowSpecificSection: View {
    @EnvironmentObject var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Section(header: Text(Strings.Library.Filter.showSpecificSectionHeader)) {
            // MARK: - Show Type
            FilterShowTypePicker()
            // MARK: - Number of Seasons
            FilterNumberOfSeasonsPicker()
        }
    }
}

#Preview {
    FilterShowSpecificSection()
        .previewEnvironment()
}
