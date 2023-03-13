//
//  CastMemberRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct CastMemberRow: View {
    let castMember: CastMemberDummy
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: castMember.imagePath.map { imagePath in
                Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.castImageSize)
            }) { image in
                image
                    .thumbnail()
            } placeholder: {
                Image(JFLiterals.posterPlaceholderName)
                    .thumbnail()
            }
            VStack(alignment: .leading) {
                Text(verbatim: castMember.name)
                    .bold()
                Text(Strings.Detail.castMemberRole(castMember.roleName))
                    .italic()
            }
        }
    }
}

struct CastMemberRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CastMemberRow(castMember: .init(id: -1, name: "Keanu Reeves", roleName: "Neo", imagePath: nil))
        }
    }
}
