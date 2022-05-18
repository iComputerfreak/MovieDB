//
//  LegalView.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import SwiftUI

// TODO: Localize
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
                Text("""
                    This app uses data from The Movie Database.
                    This product uses the TMDb API but is not endorsed or certified by TMDb.
                    """) // TODO: DO NOT TRANSLATE (?)
                HStack {
                    tmdbLogo
                    Link("https://www.themoviedb.org/", destination: URL(string: "https://www.themoviedb.org/")!)
                }
                Divider()
                Text(
                    "legal.legalNotice \("[legal@jonasfreyapps.de](mailto:legal@joansfreyapps.de)")",
                    comment: "The legal notice in the legal view. The parameter is the legal e-mail address."
                )
                Divider()
                Text(
                    "legal.appIconAttribution \("[https://uxwing.com](https://uxwing.com)")",
                    comment: "The attribution for the app icon. The parameter is the attribution link."
                )
            }
        }
        .lineLimit(nil)
        .padding()
        .navigationTitle(String(
            localized: "legal.navBar.title",
            comment: "The navigation bar title for the legal view"
        ))
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LegalView()
        }
    }
}
