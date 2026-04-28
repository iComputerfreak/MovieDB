//
//  UserData.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Analytics
import SwiftUI

/// Represents the user data section in the ``MediaDetail`` view
struct LegacyUserData: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.isEditing) private var isEditing

    private var watchStateTrackingValue: String {
        if let movie = mediaObject as? Movie {
            return movie.watched?.rawValue ?? "unknown"
        }

        if let show = mediaObject as? Show {
            switch show.watched {
            case .none:
                return "unknown"
            case .notWatched:
                return "not_watched"
            case let .season(season):
                return "season_\(season)"
            case let .episode(season, episode):
                return "season_\(season)_episode_\(episode)"
            }
        }

        return "unknown"
    }
    
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
                            return "—"
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
                        seasons: show.seasons
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
            .onChange(of: mediaObject.personalRating) { _, _ in
                AnalyticsService.shared.track(.personalRatingChanged)
            }
            .onChange(of: watchStateTrackingValue) { _, _ in
                AnalyticsService.shared.track(.watchStateChanged)
            }
        }
    }
}

#Preview("Movie") {
    List {
        LegacyUserData()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
        LegacyUserData()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .environment(\.isEditing, true)
    }
}

#Preview("Show") {
    List {
        LegacyUserData()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
        LegacyUserData()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .environment(\.isEditing, true)
    }
}
