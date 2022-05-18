//
//  LibraryHome.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import Combine

struct LibraryHome: View {
    // The filter setting (non-persistent)
    @State private var filterSetting = FilterSetting()
    
    @State private var activeSheet: ActiveSheet?
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var searchText: String = ""
    
    @State private var sortingOrder: SortingOrder = {
        if let rawValue = UserDefaults.standard.string(forKey: JFLiterals.Keys.sortingOrder) {
            return SortingOrder(rawValue: rawValue)!
        }
        return .default
    }() {
        didSet {
            UserDefaults.standard.set(self.sortingOrder.rawValue, forKey: JFLiterals.Keys.sortingOrder)
        }
    }
    @State private var sortingDirection: SortingDirection = {
        if let rawValue = UserDefaults.standard.string(forKey: JFLiterals.Keys.sortingDirection) {
            return SortingDirection(rawValue: rawValue)!
        }
        return SortingOrder.default.defaultDirection
    }() {
        didSet {
            UserDefaults.standard.set(self.sortingDirection.rawValue, forKey: JFLiterals.Keys.sortingDirection)
        }
    }
    
    var body: some View {
        // Use the proxy to scroll to a specific item after adding it
        ScrollViewReader { _ in
            NavigationView {
                VStack {
                    // We don't provide the searchText as a Binding to force a re-creation of the list whenever the searchText changes.
                    // This way, the fetchRequest inside LibraryList will be re-built every time the searchText changes
                    LibraryList(
                        searchText: searchText,
                        filterSetting: filterSetting,
                        sortingOrder: sortingOrder,
                        sortingDirection: sortingDirection
                    )
                    .searchable(text: $searchText)
                }
                
                // Display the currently active sheet
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .addMedia:
                        AddMediaView()
                            .environment(\.managedObjectContext, managedObjectContext)
                    case .filter:
                        FilterView(filterSetting: $filterSetting)
                            .environment(\.managedObjectContext, managedObjectContext)
                        // FUTURE: Open new item in editing mode
//                        .sheet(item: $addedMedia, content: MediaDetail().environmentObject(_:))
                    }
                }
                
                .navigationBarItems(
                    leading: Menu {
                        Section {
                            let filterImageReset = "line.horizontal.3.decrease.circle"
                            let filterImageSet = "line.horizontal.3.decrease.circle.fill"
                            let filterImage = self.filterSetting.isReset ? filterImageReset : filterImageSet
                            Button(action: showFilter, label: { Label("Filter", systemImage: filterImage) })
                        }
                        // MARK: Sorting Options
                        Section {
                            // To allow toggling the sorting direction, we need to use a custom binding as proxy
                            let sortingOrderProxy = Binding<SortingOrder> {
                                self.sortingOrder
                            } set: { newValue in
                                if self.sortingOrder == newValue {
                                    // Toggle the direction when tapping an already selected item
                                    self.sortingDirection.toggle()
                                } else {
                                    // Otherwise, use the default direction for this sorting order
                                    self.sortingDirection = newValue.defaultDirection
                                }
                                self.sortingOrder = newValue
                            }
                            Picker(selection: sortingOrderProxy) {
                                ForEach(SortingOrder.allCases, id: \.rawValue) { order in
                                    if self.sortingOrder == order {
                                        Label(
                                            order.localized,
                                            systemImage: sortingDirection == .ascending ? "chevron.up" : "chevron.down"
                                        )
                                        .tag(order)
                                    } else {
                                        Text(order.localized)
                                            .tag(order)
                                    }
                                }
                            } label: {
                                Text(
                                    "Sorting",
                                    comment: "Heading for the sorting direction picker in the library menu"
                                )
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    },
                    trailing: Button {
                        self.activeSheet = .addMedia
                    } label: {
                        Image(systemName: "plus")
                    }
                        .accessibilityIdentifier("add-media")
                )
                .navigationBarTitle(String(
                    localized: "tabView.library.label",
                    comment: "The label of the library tab of the main TabView"
                ))
            }
        }
    }
    
    func showFilter() {
        self.activeSheet = .filter
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
