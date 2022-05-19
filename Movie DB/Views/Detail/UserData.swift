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
            Section(
                header: HStack {
                    Image(systemName: "person.fill")
                    Text(
                        "detail.userData.header",
                        comment: "The section header for the user data section in the detail view"
                    )
                }
            ) {
                // Rating
                RatingView(rating: $mediaObject.personalRating)
                    .environment(\.editMode, editMode)
                    .headline(
                        "detail.userData.headline.personalRating",
                        comment: "The headline for the 'personal rating' property in the detail view"
                    )
                // Watched field
                if mediaObject.type == .movie {
                    SimpleValueView<MovieWatchState?>(
                        values: [.watched, .notWatched, nil],
                        value: .init(
                            // swiftlint:disable force_cast
                            get: { (self.mediaObject as! Movie).watched },
                            set: { (self.mediaObject as! Movie).watched = $0 }
                            // swiftlint:enable force_cast
                        ),
                        // TODO: Should be a view not a string
                        label: { state in
                            if let state = state {
                                switch state {
                                case .watched:
                                    return String(
                                        localized: "detail.userData.watched.picker.watched",
                                        comment: "The picker value of the detail view's user data section which the user chooses if they watched the media object"
                                    )
                                case .notWatched:
                                    return String(
                                        localized: "detail.userData.notWatched.picker.watched",
                                        comment: "The picker value of the detail view's user data section which the user chooses if they did not watch the media object"
                                    )
                                }
                            }
                            return "-"
                        }
                    )
                    // swiftlint:enable force_cast
                    .environment(\.editMode, editMode)
                    .headline(
                        "detail.userData.headline.watched",
                        comment: "The headline for the 'watched' property in the detail view"
                    )
                } else {
                    // Has watched show field
                    // swiftlint:disable force_cast
                    WatchedShowView(lastWatched: .init(
                        get: { (mediaObject as! Show).lastWatched },
                        set: { (mediaObject as! Show).lastWatched = $0 }
                    ))
                    // swiftlint:enable force_cast
                    .environment(\.editMode, editMode)
                    .headline(
                        "detail.userData.headline.watched",
                        comment: "The headline for the 'watched' property in the detail view"
                    )
                }
                // Watch again field
                SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
                    .environment(\.editMode, editMode)
                    .headline(
                        "detail.userData.headline.watchAgain",
                        comment: "The headline for the 'watch again' property in the detail view"
                    )
                // Taglist
                TagListView($mediaObject.tags)
                    .environment(\.editMode, editMode)
                    .headline(
                        "detail.userData.headline.tags",
                        comment: "The headline for the 'tags' property in the detail view"
                    )
                // Notes
                if !mediaObject.notes.isEmpty || (editMode?.wrappedValue.isEditing ?? false) {
                    NotesView($mediaObject.notes)
                        .environment(\.editMode, editMode)
                        .headline(
                            "detail.userData.headline.notes",
                            comment: "The headline for the 'notes' property in the detail view"
                        )
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
