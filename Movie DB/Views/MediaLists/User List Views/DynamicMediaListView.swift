//
//  UserListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a media list that is defined by a filter and dynamically updates according to the filter
struct DynamicMediaListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var list: DynamicMediaList
    @ObservedObject var filterSetting: FilterSetting
    @Binding var selectedMedia: Media?
    @State private var isShowingConfiguration = false
    
    init(list: DynamicMediaList, selectedMedia: Binding<Media?>) {
        self.list = list
        // We need to store the filter setting separately to be able to observe it
        assert(list.filterSetting != nil)
        // The filter setting should never be nil, since we make sure of that in FilterSetting.awakeFromFetch
        self.filterSetting = list.filterSetting!
        self._selectedMedia = selectedMedia
    }
    
    var body: some View {
        // Default destination
        FilteredMediaList(list: list, selectedMedia: $selectedMedia) { media in
            LibraryRow()
                .environmentObject(media)
        }
        .toolbar {
            ListConfigurationButton($isShowingConfiguration)
        }
        // MARK: Editing View / Configuration View
        .sheet(isPresented: $isShowingConfiguration) {
            DynamicListConfigurationView(list: list)
        }
    }
}

// TODO: Move
struct DynamicListConfigurationView: View {
    @ObservedObject var list: DynamicMediaList
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State var cancellable: AnyCancellable?
    
    init(list: DynamicMediaList) {
        self.list = list
        if list.filterSetting == nil {
            print("List has no FilterSetting. Creating a new one.")
            assertionFailure("List should have a FilterSetting.")
            list.filterSetting = FilterSetting(context: managedObjectContext)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: List Details
                // This binding uses the global list property defined in DynamicMediaListView, not the parameter
                // given into the closure
                MediaListEditingSection(name: $list.name, iconName: $list.iconName)
                // MARK: Filter Details
                FilterUserDataSection()
                FilterInformationSection()
                    .environmentObject(list.filterSetting!)
                FilterShowSpecificSection()
            }
            .environmentObject(list.filterSetting!)
            .navigationTitle(list.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(Strings.Generic.dismissViewDone) {
                    dismiss()
                }
            }
        }
    }
}

struct MediaTypeSection: View {
    @Binding var filterSetting: FilterSetting?
    
    private var mediaTypeProxy: Binding<String> {
        .init(get: {
            self.filterSetting?.mediaType?.rawValue ?? FilterView.nilString
        }, set: { type in
            self.filterSetting?.mediaType = type == FilterView.nilString ? nil : MediaType(rawValue: type)
        })
    }
    
    var body: some View {
        Picker(Strings.Library.Filter.mediaTypeLabel, selection: mediaTypeProxy) {
            Text(Strings.Library.Filter.valueAny)
                .tag(FilterView.nilString)
            Text(Strings.movie)
                .tag(MediaType.movie.rawValue)
            Text(Strings.show)
                .tag(MediaType.show.rawValue)
            
                .navigationTitle(Strings.Library.Filter.mediaTypeNavBarTitle)
        }
    }
}

struct DynamicMediaListView_Previews: PreviewProvider {
    static let previewList: DynamicMediaList = {
        PersistenceController.previewContext.reset()
        let list = DynamicMediaList(context: PersistenceController.previewContext)
        list.name = "Test"
        list.iconName = "heart.fill"
        list.sortingOrder = .name
        list.sortingDirection = .ascending
        return list
    }()
    
    static var previews: some View {
        NavigationStack {
            DynamicMediaListView(list: Self.previewList, selectedMedia: .constant(nil))
                .environment(\.managedObjectContext, PersistenceController.previewContext)
        }
    }
}
