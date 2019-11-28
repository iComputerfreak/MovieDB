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
    
    private var cast: [CastMember] {
        // Assured by superview, that those are not nil
        mediaObject.tmdbData!.cast!
    }
    
    var body: some View {
        List {
            ForEach(cast) { (member: CastMember) in
                HStack {
                    TMDBPoster(thumbnail: Binding(get: {
                        self.personThumbnails[member.id] ?? nil
                    }, set: { _ in }))
                    Text(member.name)
                        .headline(member.roleName)
                }
            }
        }
        .onAppear {
            self.loadPersonThumbnails()
        }
    }
    
    func loadPersonThumbnails() {
        guard let cast = self.mediaObject.tmdbData?.cast else {
            return
        }
        print("Loading person thumbnails for \(mediaObject.tmdbData!.title)")
        for member in cast {
            if let imagePath = member.imagePath {
                JFUtils.loadImage(urlString: JFUtils.getTMDBImageURL(path: imagePath)) { (image) in
                    DispatchQueue.main.async {
                        self.personThumbnails[member.id] = image
                    }
                }
            }
        }
    }
}

struct CastInfo_Previews: PreviewProvider {
    static var previews: some View {
        CastInfo()
    }
}
