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
                Text("This app uses data from The Movie Database.")
                    // Without this, it does not wrap the line
                    .fixedSize(horizontal: false, vertical: true)
                Text("This product uses the TMDb API but is not endorsed or certified by TMDb.") // DO NOT TRANSLATE (?)
                    // Without this, it does not wrap the line
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    tmdbLogo
                    Link("https://www.themoviedb.org/", destination: URL(string: "https://www.themoviedb.org/")!)
                }
                Divider()
                Text("All content and images are properties of their respective owners.")
                    // Without this, it does not wrap the line
                    .fixedSize(horizontal: false, vertical: true)
                Text("For legal concerns, contact")
                    // Without this, it does not wrap the line
                    .fixedSize(horizontal: false, vertical: true)
                Link("legal@jonasfreyapps.de", destination: URL(string: "mailto:legal@joansfreyapps.de")!)
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
