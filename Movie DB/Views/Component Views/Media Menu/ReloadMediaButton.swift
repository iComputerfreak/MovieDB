// Copyright © 2023 Jonas Frey. All rights reserved.

import Analytics
import CoreData
import os.log
import SwiftUI

struct ReloadMediaButton: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(NotificationProxy.self) private var notificationProxy: NotificationProxy
    @Environment(\.managedObjectContext) private var managedObjectContext
    @State private var errorMessage: String?
    var onAction: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onAction?()
            let mediaID = mediaObject.objectID
            Task(priority: .userInitiated) {
                do {
                    try await TMDBAPI.shared.updateMedia(mediaID, context: managedObjectContext)
                    await PersistenceController.saveContext(managedObjectContext)
                    notificationProxy.show(
                        title: Strings.Detail.reloadCompleteNotificationTitle,
                        systemImage: "checkmark"
                    )
                } catch {
                    Logger.library.error(
                        "Error updating \(mediaObject.title, privacy: .public): \(error, privacy: .public)"
                    )
                    errorMessage = Strings.Library.Alert.updateErrorMessage(
                        mediaObject.title,
                        error.localizedDescription
                    )
                }
            }
        } label: {
            Label(Strings.Library.mediaActionReload, systemImage: "arrow.clockwise")
        }
        .messageAlert(title: Strings.Library.Alert.updateErrorTitle, message: $errorMessage)
    }
}

#Preview {
    ReloadMediaButton()
        .previewEnvironment()
}
