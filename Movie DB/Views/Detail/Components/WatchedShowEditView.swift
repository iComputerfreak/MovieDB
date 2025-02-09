//
//  WatchedShowEditView.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.01.24.
//  Copyright © 2024 Jonas Frey. All rights reserved.
//

import SwiftUI

struct WatchedShowEditView: View {
    @Binding var watched: ShowWatchState?
    let seasons: Set<Season>
    @EnvironmentObject private var mediaObject: Media
    
    var maxSeason: Int? {
        guard let show = mediaObject as? Show else {
            assertionFailure()
            return nil
        }
        return show.latestNonEmptySeasonNumber
    }
    
    var maxEpisode: Int? {
        guard let season = seasons.first(where: \.seasonNumber, equals: self.season) else {
            // If we cannot find a matching season, we cannot say if the episode count is valid
            return nil
        }
        return season.episodeCount
    }
    
    @State private var season: Int
    @State private var episode: Int
    
    @State private var watchStateOption: WatchedShowView.WatchStateOption
    
    init(watched: Binding<ShowWatchState?>, seasons: Set<Season>) {
        _watched = watched
        // If a season is 0 (e.g., because the show is marked as .notWatched), we clamp it to 1,
        // as the "not watched" part is already acomplished by the watchStateOption
        _season = State(wrappedValue: watched.wrappedValue?.season.clamped(to: 1...1000) ?? 1)
        _episode = State(wrappedValue: watched.wrappedValue?.episode?.clamped(to: 1...1000) ?? 1)
        _watchStateOption = .init(wrappedValue: .init(showWatchState: watched.wrappedValue))
        self.seasons = seasons
    }
    
    var seasonWarningText: Text? {
        guard !isSeasonValid else {
            // No warning
            return nil
        }
        guard let show = mediaObject as? Show else {
            assertionFailure("EnvironmentObject of \(String(describing: Self.self)) is not a Show")
            return nil
        }
        
        // MARK: Option 1: The entered seasons does not have episodes out yet
        if let season = show.seasons.first(where: \.seasonNumber, equals: self.season) {
            assert(
                season.episodeCount == 0,
                "There exists a season with count > 0, so seasonIsValid should be true"
            )
            // Warning: Selected season does not have any episodes
            return Text(
                "detail.showWatchState.seasonWarningNoEpisodes \(season)",
                // swiftlint:disable:next line_length
                comment: "Warning text displayed when selecting a season as watched that does not have any episodes out yet."
            )
        }
        
        // MARK: Option 2: The entered season does not exist
        return Text("detail.showWatchState.seasonWarning \(maxSeason ?? 0)")
    }
    
    var episodeWarningText: Text? {
        guard !isEpisodeValid else {
            // No warning
            return nil
        }
        
        // MARK: The entered episode does not exist
        return Text("detail.showWatchState.episodeWarning \(maxEpisode ?? 0)")
    }
    
    var isSeasonValid: Bool {
        guard let maxSeason else { return true }
        return season <= maxSeason
    }
    
    var isEpisodeValid: Bool {
        guard let maxEpisode else { return true }
        return self.episode <= maxEpisode
    }
    
    @ViewBuilder var warningFooter: some View {
        VStack {
            if !isSeasonValid, watchStateOption == .season || watchStateOption == .episode {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    seasonWarningText
                }
            }
            if !isEpisodeValid, watchStateOption == .episode {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    episodeWarningText
                }
            }
        }
    }
    
    var body: some View {
        Form {
            Section(
                header: Text(Strings.Detail.watchedShowEditingHeader),
                footer: warningFooter
            ) {
                Picker(selection: $watchStateOption.animation()) {
                    ForEach(WatchedShowView.WatchStateOption.allCases, id: \.rawValue) { option in
                        Text(option.localized)
                            .tag(option)
                    }
                } label: {
                    Text(
                        "detail.userData.watchedShow.statusPickerLabel",
                        comment: "The label of the picker that lets the user select a show watch state."
                    )
                }
                // Seasons
                if watchStateOption == .season || watchStateOption == .episode {
                    Stepper(value: $season, in: 1...1000) {
                        Text(Strings.Detail.watchedShowLabelSeason(self.season))
                            .foregroundColor(isSeasonValid ? .primary : .yellow)
                    }
                }
                // Episodes
                if watchStateOption == .episode {
                    Stepper(value: $episode, in: 1...1000) {
                        Text(Strings.Detail.watchedShowEditingLabelEpisode(self.episode))
                            .foregroundColor(isEpisodeValid ? .primary : .yellow)
                    }
                }
            }
            .onChange(of: self.season) { _, newSeason in
                switch watchStateOption {
                case .unknown, .notWatched:
                    // We don't use the season number for those
                    return
                case .season:
                    self.watched = .season(newSeason)
                case .episode:
                    self.watched = .episode(season: newSeason, episode: self.episode)
                }
            }
            .onChange(of: self.episode) { _, newEpisode in
                switch watchStateOption {
                case .unknown, .notWatched, .season:
                    // We don't use the episode number for those
                    return
                case .episode:
                    self.watched = .episode(season: self.season, episode: newEpisode)
                }
            }
            .onChange(of: watchStateOption) { _, newValue in
                switch newValue {
                case .unknown:
                    self.watched = nil
                case .notWatched:
                    self.watched = .notWatched
                case .season:
                    self.watched = .season(self.season)
                case .episode:
                    self.watched = .episode(season: self.season, episode: self.episode)
                }
            }
        }
    }
}

#Preview {
    WatchedShowEditView(watched: .constant(.episode(season: 2, episode: 5)), seasons: [])
        .environmentObject(PlaceholderData.preview.staticShow as Media)
        .previewEnvironment()
}
