//
//  ProblemsLibraryRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct ProblemsLibraryRow: View {
    @EnvironmentObject var mediaObject: Media
    
    var missing: String {
        mediaObject.missingInformation()
            .map(\.localized)
            .sorted()
            .formatted()
    }
    
    var body: some View {
        HStack {
            Image(uiImage: mediaObject.thumbnail, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail()
            VStack(alignment: .leading) {
                Text(mediaObject.title)
                    .lineLimit(2)
                    .font(.headline)
                // Under the title
                HStack {
                    Text(Strings.Problems.missingList(missing))
                        .font(.caption)
                        .italic()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            ProblemsLibraryRow()
                .environmentObject(PlaceholderData.preview.staticProblemShow as Media)
        }
        .navigationTitle(Text(verbatim: "Library"))
    }
}
