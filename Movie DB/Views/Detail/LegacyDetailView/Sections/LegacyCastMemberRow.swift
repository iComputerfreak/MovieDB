// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

struct LegacyCastMemberRow: View {
    let castMember: CastMemberDummy
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: castMember.imagePath.map { imagePath in
                Utils.getTMDBImageURL(path: imagePath, size: JFLiterals.castImageSize)
                // swiftlint:disable:next redundant_nil_coalescing
            } ?? nil) { image in
                image
                    .thumbnail()
            } placeholder: {
                Image(uiImage: UIImage.posterPlaceholder)
                    .thumbnail()
            }

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
