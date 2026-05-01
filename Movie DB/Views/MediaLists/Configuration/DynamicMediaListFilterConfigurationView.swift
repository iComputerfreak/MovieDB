// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct DynamicMediaListFilterConfigurationView: View {
    let onDismiss: DismissAction?

    var body: some View {
        Form {
            // MARK: Filter Details
            FilterUserDataSection()
            FilterInformationSection()
            FilterShowSpecificSection()
        }
        .navigationTitle(Text(
            "lists.configuration.navTitle.filterSettings",
            comment: "The navigation title for the list configuration view's filter settings."
        ))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                DismissButton(onDismiss: { onDismiss?() })
            }
        }
    }
}

#Preview {
    DynamicMediaListFilterConfigurationView(onDismiss: nil)
}
