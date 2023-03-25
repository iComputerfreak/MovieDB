//
//  LibraryToolbar.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct LibraryToolbar: ToolbarContent {
    @Binding var config: LibraryViewConfig
    @EnvironmentObject private var filterSetting: FilterSetting
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Section {
                    let filterImageReset = "line.horizontal.3.decrease.circle"
                    let filterImageSet = "line.horizontal.3.decrease.circle.fill"
                    let filterImage = filterSetting.isReset ? filterImageReset : filterImageSet
                    Button {
                        config.activeSheet = .filter
                    } label: {
                        Label(
                            Strings.Library.menuButtonFilter,
                            systemImage: filterImage
                        )
                    }
                }
                // MARK: Sorting Options
                SortingMenuSection(sortingOrder: $config.sortingOrder, sortingDirection: $config.sortingDirection)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        // Reactivate when actions and multiselection is implemented
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                config.activeSheet = .addMedia
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityIdentifier("add-media")
        }
    }
}
