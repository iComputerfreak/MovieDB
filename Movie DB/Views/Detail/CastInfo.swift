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
    
    private var movieData: TMDBMovieData? {
        mediaObject.tmdbData as? TMDBMovieData
    }
    
    private var showData: TMDBShowData? {
        mediaObject.tmdbData as? TMDBShowData
    }
    
    var body: some View {
        mediaObject.tmdbData?.cast.map { (cast: [CastMember]) in
            Section(header: Text("Cast")) {
                ForEach(cast, id: \.self) { (member: CastMember) in
                    Text(member.name)
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
