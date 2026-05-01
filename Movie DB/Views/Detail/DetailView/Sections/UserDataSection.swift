// Copyright © 2026 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct UserDataSection: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.isEditing) private var isEditing

    private var watchAgainTitle: String {
        mediaObject.type == .show ? Strings.Detail.watchAgainHeadlineShow : Strings.Detail.watchAgainHeadline
    }

    private var movieWatchedBinding: Binding<MovieWatchState?>? {
        guard let movie = mediaObject as? Movie else { return nil }
        return .init(
            get: { movie.watched },
            set: { movie.watched = $0 }
        )
    }

    private var showWatchedBinding: Binding<ShowWatchState?>? {
        guard let show = mediaObject as? Show else { return nil }
        return .init(
            get: { show.watched },
            set: { show.watched = $0 }
        )
    }

    private var watchedSummary: String {
        if let movie = mediaObject as? Movie {
            switch movie.watched {
            case .watched:
                return Strings.Detail.watchedPickerValueYes
            case .partially:
                return Strings.Detail.watchedPickerValuePartially
            case .notWatched:
                return Strings.Detail.watchedPickerValueNo
            case nil:
                return "—"
            }
        }

        if let show = mediaObject as? Show {
            switch show.watched {
            case .none:
                return Strings.Detail.watchedShowLabelUnknown
            case .notWatched:
                return Strings.Detail.watchedShowLabelNo
            case let .season(season):
                return Strings.Detail.watchedShowLabelSeason(season)
            case let .episode(season, episode):
                return Strings.Detail.watchedShowLabelSeasonEpisode(season, episode)
            }
        }

        return "—"
    }

    private var watchAgainSummary: String {
        switch mediaObject.watchAgain {
        case true:
            return Strings.Generic.pickerValueYes
        case false:
            return Strings.Generic.pickerValueNo
        case nil:
            return "—"
        }
    }

    private var watchDateSummary: String {
        mediaObject.watchDate?.formatted(date: .abbreviated, time: .omitted) ?? Strings.Generic.unknown
    }

    private var notePreview: String {
        mediaObject.notes.isEmpty ? Strings.Detail.noNotesLabel : mediaObject.notes
    }

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
        GroupBoxSection(title: Strings.Detail.userDataSectionHeader) {
            UserDataCard(title: Strings.Detail.personalRatingHeadline, systemImage: "star.leadinghalf.filled") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 12) {
                        StarRatingView(rating: mediaObject.personalRating)
                            .font(.title3)
                            .foregroundStyle(.yellow)

                        Text(Strings.Detail.personalRatingValueLabel(mediaObject.personalRating.doubleRepresentation))
                            .font(.headline)
                            .foregroundStyle(mediaObject.personalRating == .noRating ? .secondary : .primary)

                        Spacer(minLength: 0)

                        if isEditing {
                            Stepper(
                                Strings.Detail.personalRatingHeadline,
                                value: $mediaObject.personalRating,
                                in: StarRating.noRating...StarRating.fiveStars
                            )
                            .labelsHidden()
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.Detail.watchedHeadline)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        watchedEditor
                    }
                }
            }

            if isEditing {
                VStack(spacing: 12) {
                    UserDataCard(title: watchAgainTitle, systemImage: "arrow.clockwise") {
                        SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
                    }

                    UserDataCard(title: Strings.Detail.watchDateHeadline, systemImage: "calendar") {
                        WatchDateView.EditingView()
                    }
                }
            } else {
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                    UserDataCard(title: watchAgainTitle, systemImage: "arrow.clockwise") {
                        Text(watchAgainSummary)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    UserDataCard(title: Strings.Detail.watchDateHeadline, systemImage: "calendar") {
                        Text(watchDateSummary)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            if isEditing {
                NavigationLink(value: TagListView.NavigationDestination.editing) {
                    UserDataCard(title: Strings.Detail.tagsHeadline, systemImage: "tag.fill") {
                        UserDataTagCloudView(tags: mediaObject.tags)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            } else {
                UserDataCard(title: Strings.Detail.tagsHeadline, systemImage: "tag.fill") {
                    UserDataTagCloudView(tags: mediaObject.tags)
                }
            }

            if !mediaObject.notes.isEmpty || isEditing {
                if isEditing {
                    NavigationLink {
                        NotesView.EditView(notes: $mediaObject.notes)
                    } label: {
                        UserDataCard(title: Strings.Detail.notesHeadline, systemImage: "note.text") {
                            UserDataNotePreviewView(
                                notePreview: notePreview,
                                isEmpty: mediaObject.notes.isEmpty,
                                isEditing: isEditing
                            )
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink {
                        LongTextView.ContentView(text: mediaObject.notes)
                            .navigationTitle(Strings.Detail.notesHeadline)
                    } label: {
                        UserDataCard(title: Strings.Detail.notesHeadline, systemImage: "note.text") {
                            UserDataNotePreviewView(
                                notePreview: notePreview,
                                isEmpty: mediaObject.notes.isEmpty,
                                isEditing: isEditing
                            )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onChange(of: mediaObject.personalRating) { _, _ in
            AnalyticsService.shared.track(.personalRatingChanged)
        }
        .onChange(of: watchStateTrackingValue) { _, _ in
            AnalyticsService.shared.track(.watchStateChanged)
        }
    }

    @ViewBuilder private var watchedEditor: some View {
        if isEditing {
            if let movieWatchedBinding {
                SimpleValueView<MovieWatchState?>(
                    values: MovieWatchState.allCases + [nil],
                    value: movieWatchedBinding,
                    label: { state in
                        switch state {
                        case .watched:
                            return Strings.Detail.watchedPickerValueYes
                        case .partially:
                            return Strings.Detail.watchedPickerValuePartially
                        case .notWatched:
                            return Strings.Detail.watchedPickerValueNo
                        case nil:
                            return "—"
                        }
                    }
                )
            } else if let show = mediaObject as? Show, let showWatchedBinding {
                NavigationLink {
                    WatchedShowEditView(watched: showWatchedBinding, seasons: show.seasons)
                        .environmentObject(mediaObject)
                } label: {
                    UserDataWatchedSummaryView(summary: watchedSummary, isEditing: isEditing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        } else {
            UserDataWatchedSummaryView(summary: watchedSummary, isEditing: isEditing)
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
