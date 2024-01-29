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
                WatchedShowEditView(watched: $watched, seasons: seasons)
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
}

#Preview {
    List {
        WatchedShowView(
            watched: .constant(.episode(season: 2, episode: 5)),
            seasons: []
        )
    }
}
