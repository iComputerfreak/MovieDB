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
                    Text(Strings.Detail.userDataSectionHeader)
                }
            ) {
                // MARK: Rating
                RatingView(rating: $mediaObject.personalRating)
                    .environment(\.editMode, editMode)
                    .headline(Strings.Detail.personalRatingHeadline)
                // MARK: Watched field
                if mediaObject.type == .movie {
                    SimpleValueView<MovieWatchState?>(
                        values: MovieWatchState.allCases + [nil],
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
                                    return Strings.Detail.watchedPickerValueYes
                                case .partially:
                                    return Strings.Detail.watchedPickerValuePartially
                                case .notWatched:
                                    return Strings.Detail.watchedPickerValueNo
                                }
                            }
                            return "-"
                        }
                    )
                    // swiftlint:enable force_cast
                    .environment(\.editMode, editMode)
                    .headline(Strings.Detail.watchedHeadline)
                } else {
                    // Has watched show field
                    // swiftlint:disable force_cast
                    WatchedShowView(watched: .init(
                        get: { (mediaObject as! Show).watched },
                        set: { (mediaObject as! Show).watched = $0 }
                    ))
                    // swiftlint:enable force_cast
                    .environment(\.editMode, editMode)
                    .headline(Strings.Detail.watchedHeadline)
                }
                // MARK: Watch again field
                SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
                    .environment(\.editMode, editMode)
                    .headline(Strings.Detail.watchAgainHeadline)
                // MARK: Taglist
                TagListView($mediaObject.tags)
                    .environment(\.editMode, editMode)
                    .headline(Strings.Detail.tagsHeadline)
                // MARK: Notes
                if !mediaObject.notes.isEmpty || (editMode?.wrappedValue.isEditing ?? false) {
                    NotesView($mediaObject.notes)
                        .environment(\.editMode, editMode)
                        .headline(Strings.Detail.notesHeadline)
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
