//
//  UpcomingLibraryRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct UpcomingLibraryRow: View {
    static let durationFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.year, .month, .day]
        f.unitsStyle = .abbreviated
        return f
    }()
    
    @EnvironmentObject var mediaObject: Media

    var upcomingSeason: Season? {
        guard let show = mediaObject as? Show else { return nil }
        return show.seasons
            // Only include future seasons
            .filter { season in
                guard let airDate = season.airDate else { return false }
                return airDate > Date(timeIntervalSinceNow: -PredicateMediaList.Constants.pastOverscrollTime)
            }
            // Use the earliest future season
            .min(on: \.seasonNumber, by: <)
    }

    var releaseDate: Date? {
        if let movie = mediaObject as? Movie {
            return movie.releaseDate
        } else if mediaObject is Show {
            return upcomingSeason?.airDate
        } else {
            assertionFailure("Media is neither a Movie, nor a Show.")
            return nil
        }
    }
    
    var durationString: String? {
        guard let releaseDate else { return nil }

        if releaseDate > .now {
            return Self.durationFormatter.string(from: .now, to: releaseDate)
        } else {
            return Self.durationFormatter.string(from: releaseDate, to: .now)
        }
    }
    
    var body: some View {
        BaseLibraryRow {
            if let durationString {
                if mediaObject is Movie {
                    if let releaseDate, releaseDate > Date.now {
                        // Release date in future
                        Text(Strings.Lists.upcomingSubtitleMovie(durationString))
                    } else {
                        // Release date in past
                        Text(Strings.Lists.upcomingSubtitleMovieRecentlyReleased(durationString))
                            .italic()
                    }
                } else if
                    mediaObject is Show,
                    let upcomingSeasonNumber = upcomingSeason?.seasonNumber
                {
                    if let releaseDate, releaseDate > Date.now {
                        // Release date in future
                        Text(Strings.Lists.upcomingSubtitleShow(upcomingSeasonNumber, durationString))
                    } else {
                        // Release date in the past
                        Text(Strings.Lists.upcomingSubtitleShowRecentlyReleased(upcomingSeasonNumber, durationString))
                            .italic()
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            UpcomingLibraryRow()
                .environmentObject(PlaceholderData.preview.staticShow as Media)
            UpcomingLibraryRow()
                .environmentObject(PlaceholderData.preview.staticUpcomingMovie as Media)
            UpcomingLibraryRow()
                .environmentObject(PlaceholderData.preview.staticUpcomingShow as Media)
        }
        .navigationTitle(Text(verbatim: "Upcoming"))
    }
}
