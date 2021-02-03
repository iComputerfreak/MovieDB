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
        List {
            ForEach(show.seasons) { (season: Season) in
                HStack {
                    Image(uiImage: self.seasonThumbnails[season.id] ?? nil, defaultImage: JFLiterals.posterPlaceholderName)
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
        .onAppear {
            self.loadSeasonThumbnails()
        }
    }
    
    func loadSeasonThumbnails() {
        guard let show = mediaObject as? Show else { return }
        guard !show.seasons.isEmpty else {
            return
        }
        print("Loading season thumbnails for \(show.title)")
        for season in show.seasons {
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
