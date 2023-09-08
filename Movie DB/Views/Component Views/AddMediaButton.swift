//
//  AddMediaButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI

/// Adds the `Media` in the environment to the user's library
struct AddMediaButton: View {
    @EnvironmentObject private var mediaObject: Media
    
    private var alreadyAdded: Bool {
        MediaLibrary.shared.mediaExists(mediaObject.tmdbID, mediaType: mediaObject.type)
    }
    
    // TODO: Replace workaround with some other view update.
    @State private var justAdded = false
    
    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                do {
                    try await MediaLibrary.shared.addMedia(
                        tmdbID: mediaObject.tmdbID,
                        mediaType: mediaObject.type
                    )
                    // Re-render the view by changing the state variable
                    await MainActor.run {
                        justAdded = true
                    }
                } catch {
                    Logger.addMedia.error("Error adding a lookup media object: \(error, privacy: .public)")
                    await MainActor.run {
                        AlertHandler.showError(title: Strings.Generic.alertErrorTitle, error: error)
                    }
                }
            }
        } label: {
            if alreadyAdded {
                Text(Strings.AddMedia.addMediaButtonAlreadyAdded)
            } else if justAdded {
                // Never triggers because we always re-evaluate "alreadyAdded" first
                Image(systemName: "checkmark.circle")
            } else {
                Text(Strings.AddMedia.addMediaButtonAddToLibrary)
            }
        }
        .disabled(alreadyAdded)
    }
}

#Preview {
    MediaLookupDetail(tmdbID: 603, mediaType: .movie)
        .previewEnvironment()
}
