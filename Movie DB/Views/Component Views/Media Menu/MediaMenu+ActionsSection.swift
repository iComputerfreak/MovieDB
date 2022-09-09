//
//  MediaMenu+ActionsSection.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

extension MediaMenu {
    struct ActionsSection: View {
        @ObservedObject var mediaObject: Media
        @EnvironmentObject var notificationProxy: NotificationProxy
        @Environment(\.managedObjectContext) private var managedObjectContext
        
        var body: some View {
            Section {
                Button {
                    Task(priority: .userInitiated) {
                        do {
                            try await TMDBAPI.shared.updateMedia(mediaObject, context: managedObjectContext)
                            notificationProxy.show(
                                title: Strings.Detail.reloadCompleteNotificationTitle,
                                systemImage: "checkmark"
                            )
                        } catch {
                            print("Error updating \(mediaObject.title): \(error)")
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
    }
}

struct ActionsSection_Previews: PreviewProvider {
    static var previews: some View {
        MediaMenu.ActionsSection(mediaObject: PlaceholderData.movie)
    }
}
