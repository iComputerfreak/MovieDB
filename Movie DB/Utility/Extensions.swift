// Copyright © 2019 Jonas Frey. All rights reserved.

import Foundation
import SwiftUI

extension View {
    /// Prepares the view for executing in a preview environment.
    ///
    /// **Not intended for production use!**
    func previewEnvironment() -> some View {
        self
            .environment(\.managedObjectContext, PersistenceController.xcodePreviewContext)
            .environmentObject(JFConfig.shared)
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
        // Will not work, but will prevent the preview from crashing
            .environment(NotificationProxy())
            .environmentObject(FilterSetting(context: PersistenceController.createDisposableContext(forPreview: true)))
            .environment(UnifiedSearchCoordinator())
    }
}
