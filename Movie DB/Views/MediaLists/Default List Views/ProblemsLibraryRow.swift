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
    
    var missing: [String] {
        mediaObject.missingInformation()
            .map(\.localized)
            .sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            LibraryRow(subtitleContent: .problems(missing))
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
