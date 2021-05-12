//
//  LibraryHome.swift
//  Movie DB
//
//  Created by Jonas Frey on 01.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import Combine

struct LibraryHome : View {
    
    enum ActiveSheet: Identifiable {
        case addMedia
        case filter
        
        var id: Int { hashValue }
    }
    
    @ObservedObject private var library = MediaLibrary.shared
    // The filter setting
    @ObservedObject private var filterSetting = FilterSetting.shared
    
    @State private var activeSheet: ActiveSheet? = nil
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    // TODO: Make persistent (only locally, not via iCloud)
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
        ScrollViewReader { proxy in
            NavigationView {
                VStack {
                    // We don't provide the searchText as a Binding to force a re-creation of the list whenever the searchText changes.
                    // This way, the fetchRequest inside LibraryList will be re-built every time the searchText changes
                    LibraryList(searchText: searchBar.text, filterSetting: filterSetting, sortingOrder: sortingOrder, sortingDirection: sortingDirection)
                        .add(searchBar)
                }
                
                // Display the currently active sheet
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                        case .addMedia:
                            AddMediaView()
                                .environment(\.managedObjectContext, managedObjectContext)
                        case .filter:
                            FilterView()
                                .environment(\.managedObjectContext, managedObjectContext)
                        // FUTURE: Open new item in editing mode
                        //.sheet(item: $addedMedia, content: MediaDetail().environmentObject(_:))
                    }
                }
                
                .navigationBarItems(
                    leading: Menu {
                        Section {
                            let filterImage = self.filterSetting.isReset ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill"
                            Button(action: showFilter, label: MenuLabel(title: "Filter", image: Image(systemName: filterImage)).closure())
                        }
                        // MARK: Sorting Options
                        Section {
                            // To allow toggling the sorting direction, we need to use a custom binding as proxy
                            let sortingOrderProxy = Binding<SortingOrder> {
                                return self.sortingOrder
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
                            Picker(selection: sortingOrderProxy, label: Text("Sorting")) {
                                ForEach(SortingOrder.allCases, id: \.rawValue) { order in
                                    if self.sortingOrder == order {
                                        Label(order.rawValue, systemImage: self.sortingDirection == .ascending ? "chevron.up" : "chevron.down")
                                            .tag(order)
                                    } else {
                                        Text(order.rawValue)
                                            .tag(order)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    },
                    trailing: Button(action: {
                        self.activeSheet = .addMedia
                    }, label: {
                        Image(systemName: "plus")
                    }))
                .navigationBarTitle(Text("Library"))
            }
        }
    }
    
    private struct SortingOptionsButton: View {
        
        @Binding var sortingOrder: SortingOrder
        @Binding var sortingDirection: SortingDirection
        let order: SortingOrder
        
        var body: some View {
            Button {
                //
            } label: {
                let image = Image(systemName: "chevron.up")//sortingDirection == .ascending ? "chevron.up" : "chevron.down")
                MenuLabel(title: order.rawValue, image: sortingOrder == order ? image : nil, checked: sortingOrder == order)
            }
        }
    }
    
    private struct MenuLabel: View {
        
        let title: String
        @State var image: Image? = nil
        @State var checked: Bool = false
        
        var body: some View {
            HStack {
                Image(systemName: "checkmark")
                    .hidden(condition: !checked)
                Text(title)
                Spacer()
                if image != nil {
                    image!
                }
            }
        }
    }
    
    func showFilter() {
        self.activeSheet = .filter
    }
}

#if DEBUG
struct LibraryHome_Previews : PreviewProvider {
    static var previews: some View {
        LibraryHome()
    }
}
#endif
