//
//  LegalView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import SwiftUI

struct LegalView: View {
    var tmdbLogo: some View {
        Image("TMDb Logo", bundle: .main)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 20)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(verbatim: """
                This app uses data from The Movie Database.
                This product uses the TMDb API but is not endorsed or certified by TMDb.
                """)
                HStack {
                    tmdbLogo
                    Link(
                        // Cast to String to prevent localization
                        "https://www.themoviedb.org/" as String,
                        destination: URL(string: "https://www.themoviedb.org/")!
                    )
                }
                Divider()
                // TODO: Markdown does not work this way. Either use `+ Text(markdown)`
                // or interpret the whole localized string as markdown
                // swiftlint:disable:next force_try
                let mail = try! AttributedString(markdown: "[legal@jonasfreyapps.de](mailto:legal@joansfreyapps.de)")
                Text(Strings.Legal.legalNoticeMail(mail))
                Divider()
                // swiftlint:disable:next force_try
                let link = try! AttributedString(markdown: "[https://uxwing.com](https://uxwing.com)")
                Text(Strings.Legal.appIconAttribution(link)) // TODO: Use a separate `Link`
            }
        }
        .lineLimit(nil)
        .padding()
        .navigationTitle(Strings.Legal.navBarTitle)
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LegalView()
        }
    }
}
