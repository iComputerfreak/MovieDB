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
        Section(header: Text(
            "detail.userData.header",
            comment: "The section header for the user data section in the detail view"
        )) {
            // MARK: - Watched?
            Picker(String(
                localized: "detail.userData.watched",
                // swiftlint:disable:next line_length
                comment: "The label of the picker in the filter view to select whether the media should be marked as watched or not"
            ), selection: watchedProxy) {
                Text(
                    "library.filter.value.any",
                    // swiftlint:disable:next line_length
                    comment: "A string describing that the value of a specific media property does not matter in regards of filtering the library list and that the property may have 'any' value."
                )
                    .tag(FilterView.nilString)
                Text(
                    "generic.picker.value.yes",
                    comment: "An option in a picker view"
                )
                    .tag(true.description)
                Text(
                    "generic.picker.value.no",
                    comment: "An option in a picker view"
                )
                    .tag(false.description)
                
                    .navigationTitle("Watched?")
            }
            // MARK: - Watch Again?
            Picker("Watch again?", selection: watchAgainProxy) {
                Text(
                    "library.filter.value.any",
                    // swiftlint:disable:next line_length
                    comment: "A string describing that the value of a specific media property does not matter in regards of filtering the library list and that the property may have 'any' value."
                )
                    .tag(FilterView.nilString)
                Text(
                    "generic.picker.value.yes",
                    comment: "An option in a picker view"
                )
                    .tag(true.description)
                Text(
                    "generic.picker.value.no",
                    comment: "An option in a picker view"
                )
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
