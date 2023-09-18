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
    
    var releaseDate: Date? {
        if let movie = mediaObject as? Movie {
            return movie.releaseDate
        } else if let show = mediaObject as? Show {
            return show.seasons
                // Only include future seasons
                .filter { season in
                    season.airDate != nil && season.airDate! > .now
                }
                // Use the earliest future season
                .min(on: \.seasonNumber, by: <)?
                // Return its airDate
                .airDate
        } else {
            assertionFailure("Media is neither a Movie, nor a Show.")
            return nil
        }
    }
    
    var durationString: String? {
        guard let releaseDate else {
            return nil
        }
        return Self.durationFormatter.string(from: .now, to: releaseDate)
    }
    
    var body: some View {
        BaseLibraryRow {
            if let durationString {
                if mediaObject is Movie {
                    Text(Strings.Lists.upcomingSubtitleMovie) + Text(durationString).bold()
                } else if
                    let show = mediaObject as? Show,
                    let upcomingSeason = show.seasons
                        .filter({ $0.airDate != nil && $0.airDate! > .now })
                        .map(\.seasonNumber)
                        .min()
                { // swiftlint:disable:this opening_brace
                    Text(Strings.Lists.upcomingSubtitleShow(upcomingSeason)) + Text(durationString).bold()
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
                .environmentObject(PlaceholderData.preview.staticUpcomingMovie as Media)
            UpcomingLibraryRow()
                .environmentObject(PlaceholderData.preview.staticUpcomingShow as Media)
        }
        .navigationTitle(Text(verbatim: "Upcoming"))
    }
}
