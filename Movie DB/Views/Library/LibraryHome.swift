//
//  LibraryHome.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

struct LibraryHome: View {
    @StateObject private var filterSetting = FilterSetting.shared
    
    @State private var activeSheet: ActiveSheet?
    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var selectedMediaObjects: Set<Media> = .init()
    
    @State private var searchText: String = ""
    
    @State private var sortingOrder: SortingOrder = {
        if let rawValue = UserDefaults.standard.string(forKey: JFLiterals.Keys.sortingOrder) {
            return SortingOrder(rawValue: rawValue) ?? .default
        }
        return .default
    }() {
        didSet {
            UserDefaults.standard.set(self.sortingOrder.rawValue, forKey: JFLiterals.Keys.sortingOrder)
        }
    }

    @State private var sortingDirection: SortingDirection = {
        if let rawValue = UserDefaults.standard.string(forKey: JFLiterals.Keys.sortingDirection) {
            return SortingDirection(rawValue: rawValue) ?? SortingOrder.default.defaultDirection
        }
        return SortingOrder.default.defaultDirection
    }() {
        didSet {
            UserDefaults.standard.set(self.sortingDirection.rawValue, forKey: JFLiterals.Keys.sortingDirection)
        }
    }
    
    var body: some View {
        // TODO: This should probably be a NavigationSplitView on iPad
        NavigationStack {
            // We don't provide the searchText as a Binding to force a re-creation of the list whenever the searchText changes.
            // This way, the fetchRequest inside LibraryList.init will be re-built every time the searchText changes
            LibraryList(
                searchText: searchText,
                filterSetting: filterSetting,
                sortingOrder: sortingOrder,
                sortingDirection: sortingDirection,
                selectedMediaObjects: $selectedMediaObjects
            )
            .searchable(text: $searchText)
            .background(.thinMaterial)
            .onAppear {
                if JFConfig.shared.libraryWasReset {
                    // FUTURE: Replace with better alternative
                    // Workaround to refresh the library after the reset
                    // We toggle the sortingDirection for the fraction of a second to force a recreation of the LibraryList
                    self.sortingDirection.toggle()
                    JFConfig.shared.libraryWasReset = false
                    // Revert back to original value
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.sortingDirection.toggle()
                    }
                }
            }
            
            // Display the currently active sheet
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addMedia:
                    // FUTURE: Open new item in editing mode
                    AddMediaView()
                        .environment(\.managedObjectContext, managedObjectContext)
                case .filter:
                    FilterView(filterSetting: filterSetting)
                        .environment(\.managedObjectContext, managedObjectContext)
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section {
                            let filterImageReset = "line.horizontal.3.decrease.circle"
                            let filterImageSet = "line.horizontal.3.decrease.circle.fill"
                            let filterImage = self.filterSetting.isReset ? filterImageReset : filterImageSet
                            Button(action: showFilter) {
                                Label(
                                    Strings.Library.menuButtonFilter,
                                    systemImage: filterImage
                                )
                            }
                        }
                        // MARK: Sorting Options
                        SortingMenuSection(sortingOrder: $sortingOrder, sortingDirection: $sortingDirection)
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
                        self.activeSheet = .addMedia
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("add-media")
                }
            }
            .navigationTitle(Strings.TabView.libraryLabel)
            // FUTURE: Disable when no longer bugging around
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func showFilter() {
        activeSheet = .filter
    }
    
    enum ActiveSheet: Identifiable {
        case addMedia
        case filter
        
        var id: Int { hashValue }
    }
}

struct LibraryHome_Previews: PreviewProvider {
    static var previews: some View {
        LibraryHome()
    }
}
