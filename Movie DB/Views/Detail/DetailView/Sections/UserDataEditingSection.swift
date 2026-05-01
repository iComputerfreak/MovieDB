// Copyright © 2026 Jonas Frey. All rights reserved.

import Analytics
import SwiftUI

struct UserDataEditingSection: View {
    @EnvironmentObject private var mediaObject: Media

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
                personalRatingEditor
            }

            // MARK: Watched
            watchedEditorCard

            // MARK: Watch Again
            UserDataCard(title: watchAgainTitle, systemImage: "arrow.clockwise") {
                SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
            }

            // MARK: Watch Date
            UserDataCard(title: Strings.Detail.watchDateHeadline, systemImage: "calendar") {
                WatchDateView.EditingView()
            }

            // MARK: Tags
            NavigationLink(value: TagListView.NavigationDestination.editing) {
                UserDataCard(title: Strings.Detail.tagsHeadline, systemImage: "tag.fill") {
                    UserDataTagCloudView(tags: mediaObject.tags)
                }
                .overlay(alignment: .trailing) {
                    NavigationLinkChevron()
                        .padding(.trailing, 16)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            // MARK: Notes
            NavigationLink {
                NotesView.EditView(notes: $mediaObject.notes)
            } label: {
                UserDataCard(title: Strings.Detail.notesHeadline, systemImage: "note.text") {
                    UserDataNotePreviewView(
                        notePreview: mediaObject.notes.isEmpty ? Strings.Detail.noNotesLabel : mediaObject.notes,
                        isEmpty: mediaObject.notes.isEmpty,
                        isEditing: true
                    )
                }
            }
            .buttonStyle(.plain)
        }
        .environment(\.isEditing, true)
        .onChange(of: mediaObject.personalRating) { _, _ in
            AnalyticsService.shared.track(.personalRatingChanged)
        }
        .onChange(of: watchStateTrackingValue) { _, _ in
            AnalyticsService.shared.track(.watchStateChanged)
        }
    }

    @ViewBuilder private var personalRatingEditor: some View {
        HStack(alignment: .center, spacing: 8) {
            StarRatingView(rating: mediaObject.personalRating)
                .font(.title3)

            Text(Strings.Detail.personalRatingValueLabel(mediaObject.personalRating.doubleRepresentation))
                .font(.headline)
                .foregroundStyle(mediaObject.personalRating == .noRating ? .secondary : .primary)

            Spacer(minLength: 0)

            Stepper(
                Strings.Detail.personalRatingHeadline,
                value: $mediaObject.personalRating,
                in: StarRating.noRating...StarRating.fiveStars
            )
            .labelsHidden()
        }
    }

    @ViewBuilder private var watchedEditorCard: some View {
        if let movieWatchedBinding {
            UserDataCard(title: Strings.Detail.watchedHeadline, systemImage: "checkmark.circle") {
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
            }
        } else if let showWatchedBinding, let show = mediaObject as? Show {
            NavigationLink {
                WatchedShowEditView(watched: showWatchedBinding, seasons: show.seasons)
                    .environmentObject(mediaObject)
            } label: {
                UserDataCard(title: Strings.Detail.watchedHeadline, systemImage: "checkmark.circle") {
                    // TODO: Remove isShowingChevron parameter after setting minimum iOS version to 26.0
                    UserDataWatchedSummaryView(summary: watchedSummary, isShowingChevron: false)
                }
                .overlay(alignment: .trailing) {
                    NavigationLinkChevron()
                        .padding(.trailing, 16)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview("Movie") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataEditingSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticMovie as Media)
}

#Preview("Show") {
    NavigationStack {
        VStack(alignment: .leading) {
            UserDataEditingSection()
                .padding(16)
            Spacer()
        }
    }
    .environmentObject(PlaceholderData.preview.staticShow as Media)
}
