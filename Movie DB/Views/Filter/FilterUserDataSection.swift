//
//  FilterUserDataSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterUserDataSection: View {
    @Binding var filterSetting: FilterSetting
    
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
        Section(header: Text("User Data")) {
            // MARK: - Watched?
            Picker("Watched?", selection: watchedProxy) {
                Text("Any")
                    .tag(FilterView.nilString)
                Text("Yes")
                    .tag(true.description)
                Text("No")
                    .tag(false.description)
                
                    .navigationTitle("Watched?")
            }
            // MARK: - Watch Again?
            Picker("Watch again?", selection: watchAgainProxy) {
                Text("Any")
                    .tag(FilterView.nilString)
                Text("Yes")
                    .tag(true.description)
                Text("No")
                    .tag(false.description)
                
                    .navigationTitle("Watch again?")
            }
            // MARK: - Tags
            FilterMultiPicker(
                selection: Binding(
                    get: { Array(filterSetting.tags).sorted(by: \.name) },
                    set: { filterSetting.tags = Set($0) }
                ),
                label: { (tag: Tag) in tag.name },
                values: Array(allTags),
                titleKey: "Tags"
            )
        }
    }
}

struct FilterUserDataSection_Previews: PreviewProvider {
    static var previews: some View {
        FilterUserDataSection(filterSetting: .constant(FilterSetting()))
    }
}
