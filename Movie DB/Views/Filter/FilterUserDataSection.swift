//
//  FilterUserDataSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterUserDataSection: View {
    @EnvironmentObject var filterSetting: FilterSetting
    
    private var watchedProxy: Binding<String> {
        .init(get: {
            self.filterSetting.watched?.description ?? FilterView.nilString
        }, set: { bool in
            self.filterSetting.watched = bool == FilterView.nilString ? nil : Bool(bool)
        })
    }
    
    private var watchAgainProxy: Binding<String> {
        .init(get: {
            self.filterSetting.watchAgain?.description ?? FilterView.nilString
        }, set: { bool in
            self.filterSetting.watchAgain = bool == FilterView.nilString ? nil : Bool(bool)
        })
    }
    
    @FetchRequest(
        entity: Tag.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
    ) var allTags: FetchedResults<Tag>
    
    var body: some View {
        Section(header: Text(Strings.Library.Filter.userDataSectionHeader)) {
            // MARK: - Watched?
            Picker(Strings.Library.Filter.watchedLabel, selection: watchedProxy) {
                Text(Strings.Library.Filter.valueAny)
                    .tag(FilterView.nilString)
                Text(Strings.Generic.pickerValueYes)
                    .tag(true.description)
                Text(Strings.Generic.pickerValueNo)
                    .tag(false.description)
                
                    .navigationTitle(Strings.Library.Filter.watchedNavBarTitle)
            }
            // MARK: - Watch Again?
            Picker(Strings.Library.Filter.watchAgainLabel, selection: watchAgainProxy) {
                Text(Strings.Library.Filter.valueAny)
                    .tag(FilterView.nilString)
                Text(Strings.Generic.pickerValueYes)
                    .tag(true.description)
                Text(Strings.Generic.pickerValueNo)
                    .tag(false.description)
                
                    .navigationTitle(Strings.Library.Filter.watchAgainNavBarTitle)
            }
            // MARK: - Tags
            FilterMultiPicker(
                selection: Binding(
                    get: { Array(filterSetting.tags).sorted(by: \.name) },
                    set: { filterSetting.tags = Set($0) }
                ),
                label: { Text($0.name) },
                values: Array(allTags),
                title: Text(Strings.Library.Filter.tagsLabel)
            )
        }
    }
}

struct FilterUserDataSection_Previews: PreviewProvider {
    static var previews: some View {
        FilterUserDataSection()
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext()))
    }
}
