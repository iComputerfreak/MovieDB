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
                        Image(uiImage: self.personThumbnails[member.id] ?? nil, defaultImage: JFLiterals.posterPlaceholderName)
                            .thumbnail()
                        Text(member.name)
                            .headline(verbatim: member.roleName)
                    }
                }
            }
            .onAppear {
                self.loadPersonThumbnails()
            }
        }
    }
    
    func loadPersonThumbnails() {
        print("Loading person thumbnails for \(mediaObject.title)")
        DispatchQueue.global(qos: .userInteractive).async {
            for member in mediaObject.cast {
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
}

struct CastInfo_Previews: PreviewProvider {
    static var previews: some View {
        CastInfo()
    }
}
