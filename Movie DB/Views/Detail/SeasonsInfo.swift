//
//  SeasonsInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import os.log
import SwiftUI

struct SeasonsInfo: View {
    @EnvironmentObject private var mediaObject: Media
    /// The season thumbnails
    @State private var seasonThumbnails: [Int: UIImage?] = [:]
    
    // swiftlint:disable:next force_cast
    private var show: Show { mediaObject as! Show }
    
    // Assumes that mediaObject is a Show and !show.seasons.isEmpty
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            List {
                ForEach(show.seasons.sorted(on: \.seasonNumber, by: <)) { (season: Season) in
                    if season.overview != nil, !season.overview!.isEmpty {
                        NavigationLink {
                            ScrollView {
                                Text(season.overview!)
                                    .padding()
                                    .navigationTitle(season.name)
                            }
                        } label: {
                            SeasonInfo(season: season, thumbnail: $seasonThumbnails[season.id])
                        }
                    } else {
                        SeasonInfo(season: season, thumbnail: $seasonThumbnails[season.id])
                    }
                }
            }
            .navigationTitle(Strings.Detail.seasonsInfoNavBarTitle)
            .task(priority: .userInitiated) {
                await self.loadSeasonThumbnails()
            }
        }
    }
    
    func loadSeasonThumbnails() async {
        guard
            let show = mediaObject as? Show,
            !show.seasons.isEmpty
        else {
            return
        }
        Logger.detail.info(
            // swiftlint:disable:next line_length
            "Loading season thumbnails for \(show.title, privacy: .public) (mediaID: \(show.id?.uuidString ?? "nil", privacy: .public))"
        )
        
        // We don't use a throwing task group, since we want to fail silently.
        // Unavailable images should just not be loaded instead of showing an error message
        let images: [Int: UIImage] = await withTaskGroup(of: (Int, UIImage?).self) { group in
            for season in show.seasons {
                _ = group.addTaskUnlessCancelled {
                    guard let imagePath = season.imagePath else {
                        // Fail silently
                        return (0, nil)
                    }
                    return (season.id, try? await Utils.loadImage(with: imagePath, size: JFLiterals.thumbnailTMDBSize))
                }
            }
            
            // Accumulate results
            var results: [Int: UIImage] = [:]
            for await (seasonID, image) in group {
                guard let image else { continue }
                results[seasonID] = image
            }
            
            return results
        }
        // Update the thumbnails
        await MainActor.run {
            self.seasonThumbnails = images
        }
    }
}

struct SeasonInfo: View {
    @State var season: Season
    @Binding var thumbnail: UIImage??
    
    var body: some View {
        HStack {
            // swiftlint:disable:next redundant_nil_coalescing
            Image(uiImage: thumbnail ?? nil, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail()
            VStack(alignment: .leading) {
                Text(season.name)
                    .bold()
                if season.airDate != nil {
                    let date = season.airDate!.formatted(date: .numeric, time: .omitted)
                    Text(date).italic()
                }
                Text(Strings.Detail.seasonsInfoEpisodeCount(season.episodeCount))
            }
            .padding(.vertical)
        }
    }
}

struct SeasonsInfo_Previews: PreviewProvider {
    static var previews: some View {
        SeasonsInfo()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
    }
}
