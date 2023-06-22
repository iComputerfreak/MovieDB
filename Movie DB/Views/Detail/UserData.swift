//
//  UserInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents the user data section in the ``MediaDetail`` view
struct UserData: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.isEditing) private var isEditing
    
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
                    .headline(Strings.Detail.personalRatingHeadline)
                // MARK: Watched field
                if mediaObject.type == .movie {
                    // swiftlint:disable:next force_cast
                    let movie = mediaObject as! Movie
                    SimpleValueView<MovieWatchState?>(
                        values: MovieWatchState.allCases + [nil],
                        value: .init(
                            get: { movie.watched },
                            set: { movie.watched = $0 }
                        ),
                        label: { state in
                            if let state {
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
                    .headline(Strings.Detail.watchedHeadline)
                } else {
                    // Has watched show field
                    // swiftlint:disable:next force_cast
                    let show = mediaObject as! Show
                    WatchedShowView(
                        watched: .init(
                            get: { show.watched },
                            set: { show.watched = $0 }
                        ),
                        maxSeason: show.latestNonEmptySeasonNumber ?? show.numberOfSeasons
                    )
                }
                // MARK: Watch again field
                SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
                    .headline(
                        // swiftlint:disable:next line_length
                        mediaObject.type == .show ? Strings.Detail.watchAgainHeadlineShow : Strings.Detail.watchAgainHeadline
                    )
                // MARK: Watch Date
                WatchDateView()
                // MARK: Taglist
                TagListView($mediaObject.tags)
                // MARK: Notes
                if !mediaObject.notes.isEmpty || isEditing {
                    NotesView($mediaObject.notes)
                }
            }
        }
    }
}

struct UserData_Previews: PreviewProvider {
    static var previews: some View {
        List {
            UserData()
                .environmentObject(PlaceholderData.preview.staticMovie as Media)
            UserData()
                .environmentObject(PlaceholderData.preview.staticMovie as Media)
                .environment(\.isEditing, true)
        }
        .previewDisplayName("Movie")
        
        List {
            UserData()
                .environmentObject(PlaceholderData.preview.staticShow as Media)
            UserData()
                .environmentObject(PlaceholderData.preview.staticShow as Media)
                .environment(\.isEditing, true)
        }
        .previewDisplayName("Show")
    }
}
