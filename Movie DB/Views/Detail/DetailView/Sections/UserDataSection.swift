// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct UserDataSection: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.isEditing) private var isEditing

    var body: some View {
        GroupBoxSection(title: Strings.Detail.userDataSectionHeader) {
            RatingView(rating: $mediaObject.personalRating)
                .headline(Strings.Detail.personalRatingHeadline)

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

            SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
                .headline(
                    mediaObject.type == .show ? Strings.Detail.watchAgainHeadlineShow : Strings.Detail.watchAgainHeadline
                )

            WatchDateView()
            TagListView($mediaObject.tags)

            if !mediaObject.notes.isEmpty || isEditing {
                NotesView($mediaObject.notes)
            }
        }
    }
}

#Preview("Movie") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Movie Editing") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
    .environment(\.isEditing, true)
}

#Preview("Show") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
}

#Preview("Show Editing") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
    .environment(\.isEditing, true)
}
