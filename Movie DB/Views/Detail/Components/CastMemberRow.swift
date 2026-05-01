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
                // swiftlint:disable:next redundant_nil_coalescing
            } ?? nil) { image in
                image
                    .thumbnailStyle()
            } placeholder: {
                Image(uiImage: UIImage.posterPlaceholder)
                    .thumbnailStyle()
            }

            VStack(alignment: .leading) {
                Text(verbatim: castMember.name)
                    .bold()

                if !castMember.roleName.isEmpty {
                    Text(Strings.Detail.castMemberRole(castMember.roleName))
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
        }
    }
}

#Preview {
    List {
        CastMemberRow(castMember: .init(id: -1, name: "Keanu Reeves", roleName: "Neo", imagePath: nil))
    }
}
