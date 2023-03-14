//
//  FilterInformationSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterInformationSection: View {
    @EnvironmentObject var filterSetting: FilterSetting
    
    var body: some View {
        Section(header: Text(Strings.Library.Filter.basicInfoSectionHeader)) {
            // MARK: - Media Type
            FilterMediaTypePicker()
            // MARK: - Genres
            FilterGenresPicker()
            // MARK: - Rating
            FilterPersonalRatingPicker()
            // MARK: - Year
            FilterReleaseYearPicker()
            // MARK: - Media Status
            FilterMediaStatusPicker()
        }
    }
}

struct FilterInformationSection_Previews: PreviewProvider {
    static var previews: some View {
        FilterInformationSection()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
