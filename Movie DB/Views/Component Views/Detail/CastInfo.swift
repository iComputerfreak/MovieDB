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
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            List {
                ForEach(mediaObject.castMembersSortOrder, id: \.self) { (memberID: Int) in
                    let member: CastMember = mediaObject.cast.first(where: { $0.id == memberID })!
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
            .task {
                await self.loadPersonThumbnails()
            }
        }
    }
    
    func loadPersonThumbnails() async {
        print("Loading person thumbnails for \(mediaObject.title)")
        
        // We don't use a throwing task group, since we want to fail silently.
        // Unavailable images should just not be loaded instead of showing an error message
        let images: [Int: UIImage] = await withTaskGroup(of: (Int, UIImage?).self) { group in
            for member in mediaObject.cast {
                _ = group.addTaskUnlessCancelled {
                    guard let imagePath = member.imagePath else {
                        // Fail silently
                        return (0, nil)
                    }
                    return (member.id, try? await Utils.loadImage(with: imagePath))
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
