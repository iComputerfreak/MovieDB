//
//  WatchedShowView.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import JFUtils
import os.log
import SwiftUI

struct WatchedShowView: View {
    @Binding var watched: ShowWatchState?
    let seasons: Set<Season>
    @Environment(\.isEditing) private var isEditing
    @EnvironmentObject private var mediaObject: Media
    
    private var episodeString: String {
        guard let watched else {
            return Strings.Detail.watchedShowLabelUnknown
        }
        switch watched {
        case .notWatched:
            return Strings.Detail.watchedShowLabelNo
        case let .season(s):
            assert(s > 0)
            return Strings.Detail.watchedShowLabelSeason(s)
        case let .episode(season: s, episode: e):
            assert(e > 0)
            return Strings.Detail.watchedShowLabelSeasonEpisode(s, e)
        }
    }
    
    var body: some View {
        if isEditing {
            NavigationLink {
                EditView(watched: $watched, seasons: seasons)
                    .environmentObject(mediaObject)
            } label: {
                Text(episodeString)
                    .headline(Strings.Detail.watchedHeadline)
            }
        } else {
            Text(episodeString)
                .headline(Strings.Detail.watchedHeadline)
        }
    }
    
    enum WatchStateOption: String, CaseIterable {
        case unknown
        case notWatched
        case season
        case episode
        
        init(showWatchState: ShowWatchState?) {
            switch showWatchState {
            case nil:
                self = .unknown
            case .season:
                self = .season
            case .episode:
                self = .episode
            case .notWatched:
                self = .notWatched
            }
        }
        
        var localized: String {
            switch self {
            case .unknown:
                return String(
                    localized: "detail.userData.watchedShow.statusPickerOption.unknown",
                    // swiftlint:disable:next line_length
                    comment: "One of the picker options in the show watch state view that indicates that the user does not know if they watched the show."
                )
            case .notWatched:
                return String(
                    localized: "detail.userData.watchedShow.statusPickerOption.notWatched",
                    // swiftlint:disable:next line_length
                    comment: "One of the picker options in the show watch state view that indicates that the user did not watch the show."
                )
            case .season:
                return String(
                    localized: "detail.userData.watchedShow.statusPickerOption.season",
                    // swiftlint:disable:next line_length
                    comment: "One of the picker options in the show watch state view that indicates that the user watched the show up to a specific season."
                )
            case .episode:
                return String(
                    localized: "detail.userData.watchedShow.statusPickerOption.episode",
                    // swiftlint:disable:next line_length
                    comment: "One of the picker options in the show watch state view that indicates that the user watched the show up to a specific episode."
                )
            }
        }
    }
    
    struct EditView: View {
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
        
        @State private var watchStateOption: WatchStateOption
        
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
            guard let maxSeason else {
                return true
            }
            return season <= maxSeason
        }
        
        var isEpisodeValid: Bool {
            guard let maxEpisode else {
                return true
            }
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
                        ForEach(WatchStateOption.allCases, id: \.rawValue) { option in
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
                .onChange(of: self.season) { newSeason in
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
                .onChange(of: self.episode) { newEpisode in
                    switch watchStateOption {
                    case .unknown, .notWatched, .season:
                        // We don't use the episode number for those
                        return
                    case .episode:
                        self.watched = .episode(season: self.season, episode: newEpisode)
                    }
                }
                .onChange(of: watchStateOption) { newValue in
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
}

#Preview {
    List {
        WatchedShowView(
            watched: .constant(.episode(season: 2, episode: 5)),
            seasons: []
        )
    }
}

#Preview("Editing") {
    WatchedShowView.EditView(watched: .constant(.episode(season: 2, episode: 5)), seasons: [])
        .environmentObject(PlaceholderData.preview.staticShow as Media)
        .previewEnvironment()
}
