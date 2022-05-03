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
            .navigationBarTitle("Filter Options")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.filterSetting.reset()
                        self.dismiss()
                    } label: {
                        Text("Reset")
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button {
                        self.dismiss()
                    } label: {
                        Text("Apply")
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
