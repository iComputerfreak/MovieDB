//
//  UserInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UserData: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(header: HStack { Image(systemName: "person.fill"); Text("User Data") }) {
                // Rating
                RatingView(rating: $mediaObject.personalRating)
                    .environment(\.editMode, editMode)
                    .headline("Personal Rating")
                // Watched field
                if mediaObject.type == .movie {
                    // swiftlint:disable force_cast
//                    SimpleValueView<Bool>.createYesNo(value: .init(
//                        get: { (self.mediaObject as! Movie).watched },
//                        set: { (self.mediaObject as! Movie).watched = $0 }
//                    ))
                    SimpleValueView<MovieWatchState?>(
                        values: [.watched, .notWatched, nil],
                        value: .init(
                            get: { (self.mediaObject as! Movie).watched },
                            set: { (self.mediaObject as! Movie).watched = $0 }
                        ),
                        // TODO: Should be a view not a string
                        label: { state in
                            state?.rawValue ?? "-"
                        }
                    )
                    // swiftlint:enable force_cast
                    .environment(\.editMode, editMode)
                    .headline("Watched?")
                } else {
                    // Has watched show field
                    // swiftlint:disable force_cast
                    WatchedShowView(lastWatched: .init(
                        get: { (mediaObject as! Show).lastWatched },
                        set: { (mediaObject as! Show).lastWatched = $0 }
                    ))
                    // swiftlint:enable force_cast
                    .environment(\.editMode, editMode)
                    .headline("Watched?")
                }
                // Watch again field
                SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
                    .environment(\.editMode, editMode)
                    .headline("Watch again?")
                // Taglist
                TagListView($mediaObject.tags)
                    .environment(\.editMode, editMode)
                    .headline("Tags")
                // Notes
                if !mediaObject.notes.isEmpty || (editMode?.wrappedValue.isEditing ?? false) {
                    NotesView($mediaObject.notes)
                        .environment(\.editMode, editMode)
                        .headline("Notes")
                }
            }
        }
    }
}

struct UserData_Previews: PreviewProvider {
    static var previews: some View {
        UserData()
    }
}
