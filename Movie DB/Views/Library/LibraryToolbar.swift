// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
import CoreData
import Foundation
import JFUtils
import OSLog
import SwiftUI

struct LibraryToolbar: ToolbarContent {
    @Environment(UnifiedSearchCoordinator.self) private var unifiedSearchCoordinator
    @EnvironmentObject private var filterSetting: FilterSetting
    @Environment(\.managedObjectContext) private var managedObjectContext

    // TODO: Use @EnvironmentObject
    @Binding var config: LibraryViewModel
    #if os(iOS)
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    #endif
    @Binding var selectedMediaObjects: Set<Media>
    var allMediaObjects: Set<Media>
    
    let filterImageReset = "line.horizontal.3.decrease.circle"
    let filterImageSet = "line.horizontal.3.decrease.circle.fill"
    
    var filterImageName: String {
        filterSetting.isReset ? filterImageReset : filterImageSet
    }
    
    var body: some ToolbarContent {
        moreMenu
        #if os(iOS)
        multiSelectDoneButton
        #endif
        addMediaButton
    }
    
    @ToolbarContentBuilder
    private var moreMenu: some ToolbarContent {
        ToolbarItem(placement: .secondaryAction) {
            Menu {
                MultiSelectionMenu(selectedMediaObjects: $selectedMediaObjects, allMediaObjects: allMediaObjects)
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
                SortingMenuSection(
                    sortingOrder: $config.sortingOrder,
                    sortingDirection: $config.sortingDirection
                ) { sortingOrder, sortingDirection in
                    AnalyticsService.shared.track(
                        .libraryHomeSortingChanged(
                            sortingOrder: sortingOrder.analyticsValue,
                            sortingDirection: sortingDirection.analyticsValue
                        )
                    )
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    #if os(iOS)
    @ToolbarContentBuilder
    private var multiSelectDoneButton: some ToolbarContent {
        if editMode?.wrappedValue.isEditing == true {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    selectedMediaObjects = []
                    AnalyticsService.shared.track(.libraryHomeMultiselect(action: .exited))
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
    #endif

    @ToolbarContentBuilder
    private var addMediaButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                #if os(iOS)
                if #available(iOS 26, *) {
                    unifiedSearchCoordinator.open(scope: .addMedia)
                    return
                }
                #endif

                config.activeSheet = .addMedia(initialSearchText: "")
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityIdentifier("add-media")
        }
    }
}
