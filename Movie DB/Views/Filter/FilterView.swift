// Copyright © 2019 Jonas Frey. All rights reserved.

import CoreData
import Analytics
import SwiftUI

struct FilterView: View {
    static let nilString = "any"
    
    @EnvironmentObject var filterSetting: FilterSetting
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var managedObjectContext
        
    var body: some View {
        NavigationStack {
            Form {
                FilterUserDataSection()
                FilterInformationSection()
                FilterShowSpecificSection()
            }
            .environmentObject(filterSetting)
            .navigationTitle(Strings.Library.Filter.navBarTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.filterSetting.reset()
                        AnalyticsService.shared.track(
                            .libraryHomeFilterApplied(filterTypes: filterSetting.analyticsFilterTypes)
                        )
                        self.dismiss()
                    } label: {
                        Text(Strings.Library.Filter.navBarButtonReset)
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button {
                        AnalyticsService.shared.track(
                            .libraryHomeFilterApplied(filterTypes: filterSetting.analyticsFilterTypes)
                        )
                        self.dismiss()
                    } label: {
                        Text(Strings.Library.Filter.navBarButtonApply)
                    }
                }
            }
        }
    }
}

#Preview {
    FilterView()
        .previewEnvironment()
}
