// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct DeleteMediaButton: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var onAction: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        Button(role: .destructive) {
            onAction?()
            AnalyticsService.shared.track(.mediaDeleted(mediaType: mediaObject.type.analyticsValue))
            // Delete the media
            self.managedObjectContext.delete(mediaObject)
            onDelete?()
        } label: {
            Label(Strings.Library.swipeActionDelete, systemImage: "trash")
        }
    }
}

#Preview {
    DeleteMediaButton()
        .previewEnvironment()
}
