// Copyright © 2023 Jonas Frey. All rights reserved.

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

    var isReleased: Bool {
        guard let releaseDate else { return false }
        return releaseDate <= .now
    }

    var subtitleColor: Color {
        isReleased ? .green : .yellow
    }

    var subtitleString: String? {
        guard let durationString else { return nil }

        switch (mediaObject, isReleased) {
        case (is Movie, true):
            return Strings.Lists.upcomingSubtitleMovieRecentlyReleased(durationString)

        case (is Movie, false):
            return Strings.Lists.upcomingSubtitleMovie(durationString)

        case (is Show, true):
            if let upcomingSeasonNumber = upcomingSeason?.seasonNumber {
                return Strings.Lists.upcomingSubtitleShowRecentlyReleased(upcomingSeasonNumber, durationString)
            } else {
                return nil
            }

        case (is Show, false):
            if let upcomingSeasonNumber = upcomingSeason?.seasonNumber {
                return Strings.Lists.upcomingSubtitleShow(upcomingSeasonNumber, durationString)
            } else {
                return nil
            }

        default:
            return nil
        }
    }

    var body: some View {
        BaseLibraryRow {
            if let subtitleString {
                Text(subtitleString)
                    .foregroundStyle(subtitleColor)
                    .bold()
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            UpcomingLibraryRow()
                .environmentObject(PlaceholderData.preview.staticRecentlyReleasedMovie as Media)
            UpcomingLibraryRow()
                .environmentObject(PlaceholderData.preview.staticUpcomingMovie as Media)
            UpcomingLibraryRow()
                .environmentObject(PlaceholderData.preview.staticUpcomingShow as Media)
        }
        .navigationTitle(Text(verbatim: "Upcoming"))
    }
}
