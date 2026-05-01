// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

struct LegacyCastMemberRow: View {
    let castMember: CastMemberDummy

    private var imageURL: URL? {
        castMember.imagePath.flatMap { imagePath in
            Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.castImageSize)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            LoadableImageView(source: .url(imageURL), contentMode: .fit)
                .frame(width: JFLiterals.thumbnailSize.width, height: JFLiterals.thumbnailSize.height)
                .shadow(radius: 3, y: 3.5)

            VStack(alignment: .leading) {
                Text(verbatim: castMember.name)
                    .bold()
                if !castMember.roleName.isEmpty {
                    Text(Strings.Detail.castMemberRole(castMember.roleName))
                        .italic()
                }
            }
        }
    }
}

#Preview {
    List {
        LegacyCastMemberRow(castMember: .init(id: -1, name: "Keanu Reeves", roleName: "Neo", imagePath: nil))
    }
}
