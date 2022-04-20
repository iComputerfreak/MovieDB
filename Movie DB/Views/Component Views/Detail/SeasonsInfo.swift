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
    
    private var show: Show { mediaObject as! Show }
    
    // Assumes that mediaObject is a Show and !show.seasons.isEmpty
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            List {
                ForEach(show.seasons.sorted(by: \.seasonNumber)) { (season: Season) in
                    if season.overview != nil && !season.overview!.isEmpty {
                        NavigationLink(destination: ScrollView {
                            Text(season.overview!)
                                .padding()
                                .navigationBarTitle(season.name)
                        }) {
                            SeasonInfo(season: season, thumbnail: $seasonThumbnails[season.id])
                        }
                    } else {
                        SeasonInfo(season: season, thumbnail: $seasonThumbnails[season.id])
                    }
                }
            }
            .navigationBarTitle("Seasons")
            .onAppear {
                self.loadSeasonThumbnails()
            }
        }
    }
    
    // TODO: Make async
    func loadSeasonThumbnails() {
        guard let show = mediaObject as? Show else { return }
        guard !show.seasons.isEmpty else {
            return
        }
        print("Loading season thumbnails for \(show.title)")
        for season in show.seasons {
            if let imagePath = season.imagePath {
                Utils.loadImage(urlString: Utils.getTMDBImageURL(path: imagePath).absoluteString) { (image) in
                    DispatchQueue.main.async {
                        self.seasonThumbnails[season.id] = image
                    }
                }
            }
        }
    }
}

struct SeasonInfo: View {
    
    @State var season: Season
    @Binding var thumbnail: UIImage??
    
    var body: some View {
        HStack {
            Image(uiImage: thumbnail ?? nil, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail()
            VStack(alignment: .leading) {
                // Row 1
                HStack {
                    Text(season.name)
                        .bold()
                }
                // Row 2
                HStack {
                    if season.airDate != nil {
                        Text(Utils.dateFormatter.string(from: season.airDate!))
                    }
                    Text("\(season.episodeCount) Episodes", tableName: "Plurals")
                }
            }
            .padding(.vertical)
        }
    }
}

struct SeasonsInfo_Previews: PreviewProvider {
    static var previews: some View {
        SeasonsInfo()
            .environmentObject(PlaceholderData.movie)
    }
}
