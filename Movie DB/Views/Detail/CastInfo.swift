//
//  CastInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct CastInfo: View {
    @EnvironmentObject private var mediaObject: Media
    @State private var personThumbnails: [Int: UIImage?] = [:]
    
    @State private var cast: [CastMemberDummy] = []
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else if cast.isEmpty {
            HStack {
                ProgressView()
                Text(Strings.Generic.loadingText)
            }
            .task(priority: .userInitiated) {
                print("Loading cast for \(mediaObject.title)")
                do {
                self.cast = try await TMDBAPI.shared.cast(for: mediaObject.tmdbID, type: mediaObject.type)
                } catch {
                    AlertHandler.showError(
                        title: Strings.Detail.Alert.errorLoadingCastTitle,
                        error: error
                    )
                }
            }
        } else {
            List {
                ForEach(cast) { member in
                    HStack {
                        Image(
                            // swiftlint:disable:next redundant_nil_coalescing
                            uiImage: self.personThumbnails[member.id] ?? nil,
                            defaultImage: JFLiterals.posterPlaceholderName
                        )
                        .thumbnail()
                        Text(member.name)
                            .headline(verbatim: member.roleName)
                    }
                }
            }
            // TODO: Use AsyncImage
            .task(priority: .userInitiated) {
                await self.loadPersonThumbnails()
            }
        }
    }
    
    func loadPersonThumbnails() async {
        print("Loading person thumbnails for \(mediaObject.title)")
        
        // We don't use a throwing task group, since we want to fail silently.
        // Unavailable images should just not be loaded instead of showing an error message
        let images: [Int: UIImage] = await withTaskGroup(of: (Int, UIImage?).self) { group in
            for member in cast {
                _ = group.addTaskUnlessCancelled {
                    guard let imagePath = member.imagePath else {
                        // Fail silently
                        return (0, nil)
                    }
                    return (member.id, try? await Utils.loadImage(with: imagePath, size: JFLiterals.thumbnailTMDBSize))
                }
            }
            
            // Accumulate results
            var results: [Int: UIImage] = [:]
            for await (memberID, image) in group {
                guard let image = image else { continue }
                results[memberID] = image
            }
            
            return results
        }
        // Update the thumbnails
        await MainActor.run {
            self.personThumbnails = images
        }
    }
}

struct CastInfo_Previews: PreviewProvider {
    static var previews: some View {
        CastInfo()
    }
}
