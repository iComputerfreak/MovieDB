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
    /// The season thumbnails
    @State private var seasonThumbnails: [Int: UIImage?] = [:]
    
    private var showData: TMDBShowData? {
        mediaObject.tmdbData as? TMDBShowData
    }
    
    init() {
        loadSeasonThumbnails()
    }
    
    // Assumes that showData != nil && !showData!.seasons.isEmpty
    var body: some View {
        List {
            ForEach(showData!.seasons) { (season: Season) in
                HStack {
                    // We have to unwrap the subscript result AND the value (UIImage?)
                    if (self.seasonThumbnails[season.id] != nil && self.seasonThumbnails[season.id]! != nil) {
                        // Thumbnail image
                        Image(uiImage: self.seasonThumbnails[season.id]!!)
                            .poster()
                    } else {
                        // Placeholder image
                        JFLiterals.thumbnailPlaceholder
                            .poster()
                            .padding(5)
                    }
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
                            NavigationLink(destination: VStack {
                                Text(season.overview!)
                                    .padding()
                                Spacer()
                                    .navigationBarTitle(season.name)
                            }) {
                                Text(season.overview!)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarTitle("Seasons")
    }
    
    func loadSeasonThumbnails() {
        guard let showData = self.showData else {
            return
        }
        guard !showData.seasons.isEmpty else {
            return
        }
        print("Loading season thumbnails for \(showData.title)")
        for season in showData.seasons {
            if let imagePath = season.imagePath {
                JFUtils.loadImage(urlString: JFUtils.getTMDBImageURL(path: imagePath)) { (image) in
                    DispatchQueue.main.async {
                        self.seasonThumbnails[season.id] = image
                    }
                }
            }
        }
    }
}

struct SeasonsInfo_Previews: PreviewProvider {
    static var previews: some View {
        SeasonsInfo()
            .environmentObject(PlaceholderData.movie)
    }
}
