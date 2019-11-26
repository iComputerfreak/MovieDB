//
//  SeasonsInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct SeasonsInfo: View {
    
    @EnvironmentObject private var mediaObject: Media
    
    private var showData: TMDBShowData? {
        mediaObject.tmdbData as? TMDBShowData
    }
    
    // Assumes that showData != nil && !showData!.seasons.isEmpty
    var body: some View {
        List {
            ForEach(showData!.seasons) { (season: Season) in
                HStack {
                    TMDBPoster(thumbnail: season.thumbnail)
                    VStack(alignment: .leading) {
                        // Row 1
                        HStack {
                            Text(season.name)
                                .bold()
                        }
                        // Row 2
                        HStack {
                            if season.airDate != nil {
                                Text(JFUtils.dateFormatter.string(from: season.airDate!))
                            }
                            Text("\(season.episodeCount) Episodes")
                        }
                        // Row 3
                        if season.overview != nil && !season.overview!.isEmpty {
                            Divider()
                            Text(season.overview!)
                        }
                    }
                }
            }
        }
    }
}

struct SeasonsInfo_Previews: PreviewProvider {
    static var previews: some View {
        SeasonsInfo()
    }
}
