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
                    """) // DO NOT TRANSLATE (?)
                HStack {
                    tmdbLogo
                    Link("https://www.themoviedb.org/", destination: URL(string: "https://www.themoviedb.org/")!)
                }
                Divider()
                Text("""
                    All content and images are properties of their respective owners.
                    For legal concerns, contact [legal@jonasfreyapps.de](mailto:legal@joansfreyapps.de)
                    """)
                Divider()
                Text("App Icon: [https://uxwing.com](https://uxwing.com)")
            }
        }
        .lineLimit(nil)
        .padding()
        .navigationTitle("Legal")
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LegalView()
        }
    }
}