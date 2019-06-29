//
//  AddMediaView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import JFSwiftUI

struct AddMediaView : View {
    
    @State private var results: [TMDBSearchResult] = []
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchEditingChanged: {
                    print("Search: \(self.searchText)")
                    let api = TMDBAPI()
                    api.searchMedia(self.searchText) { (results: [TMDBSearchResult]?) in
                        guard let results = results else {
                            print("Error getting results")
                            self.results = []
                            return
                        }
                        self.results = results
                        let names = results.map( { $0.title } )
                        print(names)
                    }
                })
                List {
                    ForEach(self.results.identified(by: \.id)) { (result: TMDBSearchResult) in
                        let date: Date!
                        if result.mediaType == .movie {
                            date = (result as? TMDBMovieSearchResult)?.releaseDate
                        } else {
                            date = (result as? TMDBShowSearchResult)?.firstAirDate
                        }
                        let year = Calendar.current.component(.year, from: date)
                        SearchResultView(title: result.title, image: nil, year: year, overview: result.overview, type: result.mediaType)
                    }
                }
            }
            
            .navigationBarTitle(Text("Add Movie"), displayMode: .inline)
        }
    }
}

#if DEBUG
struct AddMediaView_Previews : PreviewProvider {
    static var previews: some View {
        AddMediaView()
    }
}
#endif
