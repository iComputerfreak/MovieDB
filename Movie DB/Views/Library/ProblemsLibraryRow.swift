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
            .joined(separator: ", ")
    }
    
    var body: some View {
        NavigationLink {
            MediaDetail()
                .environmentObject(mediaObject)
        } label: {
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
}

struct ProblemsLibraryRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ProblemsLibraryRow()
                    .environmentObject(PlaceholderData.problemShow as Media)
            }
            .navigationTitle(Text(verbatim: "Library"))
        }
    }
}