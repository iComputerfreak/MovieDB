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
    // TODO: Use @EnvironmentObject
    @Binding var config: LibraryViewModel
    @EnvironmentObject private var filterSetting: FilterSetting
    var editMode: Binding<EditMode>?
    
    let filterImageReset = "line.horizontal.3.decrease.circle"
    let filterImageSet = "line.horizontal.3.decrease.circle.fill"
    
    var filterImageName: String {
        filterSetting.isReset ? filterImageReset : filterImageSet
    }
    
    private var isEditing: Bool { editMode?.wrappedValue.isEditing ?? false }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button {
                    withAnimation {
                        editMode?.wrappedValue = isEditing ? .inactive : .active
                    }
                } label: {
                    Label(
                        Strings.Library.menuSelectLabel,
                        systemImage: isEditing ? "checkmark.circle.fill" : "checkmark.circle"
                    )
                }
                Section {
                    Button {
                        config.activeSheet = .filter
                    } label: {
                        Label(
                            Strings.Library.menuButtonFilter,
                            systemImage: filterImageName
                        )
                    }
                }
                // MARK: Sorting Options
                SortingMenuSection(sortingOrder: $config.sortingOrder, sortingDirection: $config.sortingDirection)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        if isEditing {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        editMode?.wrappedValue = .inactive
                    }
                } label: {
                    Text(Strings.Generic.editButtonLabelDone)
                        .bold()
                }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                config.activeSheet = .addMedia
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityIdentifier("add-media")
        }
    }
}
