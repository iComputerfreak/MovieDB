//
//  DeleteMediaSwipeAction.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.07.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

struct DeleteMediaSwipeAction: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        Button(role: .destructive) {
            Logger.coreData.info(
                // swiftlint:disable:next line_length
                "Deleting \(mediaObject.title, privacy: .public) (mediaID: \(mediaObject.id?.uuidString ?? "nil", privacy: .public))"
            )
            // Thumbnail on will be deleted automatically by Media::prepareForDeletion()
            self.managedObjectContext.delete(mediaObject)
            PersistenceController.saveContext(self.managedObjectContext)
        } label: {
            Image(systemName: "trash")
        }
    }
}

#Preview {
    DeleteMediaSwipeAction()
        .previewEnvironment()
}
