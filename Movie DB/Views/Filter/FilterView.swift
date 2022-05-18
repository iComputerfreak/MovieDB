//
//  FilterView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData

struct FilterView: View {
    static let nilString = "any"
    
    @Binding var filterSetting: FilterSetting
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var managedObjectContext
        
    var body: some View {
        NavigationView {
            Form {
                FilterUserDataSection(filterSetting: $filterSetting)
                FilterInformationSection(filterSetting: $filterSetting)
                FilterShowSpecificSection(filterSetting: $filterSetting)
            }
            .navigationTitle(String(
                localized: "library.filter.navBar.title",
                comment: "The navigation bar title for the library's filter view"
            ))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.filterSetting.reset()
                        self.dismiss()
                    } label: {
                        Text(
                            "library.filter.button.reset",
                            comment: "Button label for the reset button in the filter view"
                        )
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button {
                        self.dismiss()
                    } label: {
                        Text(
                            "library.filter.button.apply",
                            comment: "Button label for the apply button in the filter view"
                        )
                    }
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(filterSetting: .constant(FilterSetting()))
    }
}
