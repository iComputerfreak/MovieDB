//
//  LibraryToolbar.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import JFUtils
import OSLog
import SwiftUI

struct LibraryToolbar: ToolbarContent {
    @EnvironmentObject private var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext

    // TODO: Use @EnvironmentObject
    @Binding var config: LibraryViewModel
    var editMode: Binding<EditMode>?
    @Binding var selectedMediaObjects: Set<Media>
    var allMediaObjects: Set<Media>
    
    let filterImageReset = "line.horizontal.3.decrease.circle"
    let filterImageSet = "line.horizontal.3.decrease.circle.fill"
    
    var filterImageName: String {
        filterSetting.isReset ? filterImageReset : filterImageSet
    }
    
    var body: some ToolbarContent {
        moreMenu
        multiSelectDoneButton
        addMediaButton
    }
    
    @ToolbarContentBuilder
    private var moreMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                MultiSelectionMenu(selectedMediaObjects: $selectedMediaObjects, allMediaObjects: allMediaObjects)
                    .environment(\.editMode, editMode)
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
    }
    
    @ToolbarContentBuilder
    private var multiSelectDoneButton: some ToolbarContent {
        if editMode?.wrappedValue.isEditing == true {
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
    }
    
    @ToolbarContentBuilder
    private var addMediaButton: some ToolbarContent {
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
