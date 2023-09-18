//
//  ReloadMediaButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

struct ReloadMediaButton: View {
    @EnvironmentObject private var mediaObject: Media
    @EnvironmentObject private var notificationProxy: NotificationProxy
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                do {
                    try await TMDBAPI.shared.updateMedia(mediaObject, context: managedObjectContext)
                    await PersistenceController.saveContext(managedObjectContext)
                    notificationProxy.show(
                        title: Strings.Detail.reloadCompleteNotificationTitle,
                        systemImage: "checkmark"
                    )
                } catch {
                    Logger.library.error(
                        "Error updating \(mediaObject.title, privacy: .public): \(error, privacy: .public)"
                    )
                    AlertHandler.showSimpleAlert(
                        title: Strings.Library.Alert.updateErrorTitle,
                        message: Strings.Library.Alert.updateErrorMessage(
                            mediaObject.title,
                            error.localizedDescription
                        )
                    )
                }
            }
        } label: {
            Label(Strings.Library.mediaActionReload, systemImage: "arrow.clockwise")
        }
    }
}

#Preview {
    ReloadMediaButton()
        .previewEnvironment()
}
