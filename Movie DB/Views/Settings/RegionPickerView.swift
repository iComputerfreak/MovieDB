//
//  RegionPickerView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct RegionPickerView: View {
    @EnvironmentObject var preferences: JFConfig
    
    var sortedRegionCodes: [String] {
        Locale.Region.isoRegions.map(\.identifier).sorted { code1, code2 in
            guard let name1 = Locale.current.localizedString(forRegionCode: code1) else {
                return false
            }
            guard let name2 = Locale.current.localizedString(forRegionCode: code2) else {
                return true
            }
            return name1.lexicographicallyPrecedes(name2)
        }
    }
    
    var body: some View {
        Picker(Strings.Settings.regionNavBarTitle, selection: $preferences.region) {
            // Instead of loading the countries from TMDB, we just use all available regions
            ForEach(sortedRegionCodes, id: \.self) { code in
                let regionName = Locale.current.localizedString(forRegionCode: code) ?? code
                Text(regionName)
                    .tag(code)
            }
        }
        .pickerStyle(.navigationLink)
    }
}

#Preview {
    List {
        RegionPickerView()
            .previewEnvironment()
    }
}
