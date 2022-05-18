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
        Locale.isoRegionCodes.sorted { code1, code2 in
            let name1 = Locale.current.localizedString(forRegionCode: code1)!
            let name2 = Locale.current.localizedString(forRegionCode: code2)!
            return name1.lexicographicallyPrecedes(name2)
        }
    }
    
    var body: some View {
        Picker(String(
            localized: "settings.region.navBar.title",
            comment: "The navigation bar title for the region picker in the settings"
        ), selection: $preferences.region) {
            // Instead of loading the countries from TMDB, we just use all available regions
            ForEach(sortedRegionCodes, id: \.self) { code in
                let regionName = Locale.current.localizedString(forRegionCode: code) ?? code
                Text(regionName)
                    .tag(code)
            }
        }
    }
}

struct RegionPickerView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RegionPickerView()
                .environmentObject(JFConfig.shared)
        }
    }
}
