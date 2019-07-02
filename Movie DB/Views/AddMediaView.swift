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
    @Environment(\.isPresented) var isPresented
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchEditingChanged: {
                    print("Search: \(self.searchText)")
                    guard !self.searchText.isEmpty else {
                        self.results = []
                        return
                    }
                    let api = TMDBAPI(apiKey: JFLiterals.apiKey.rawValue)
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
                
                List(self.results.identified(by: \TMDBSearchResult.id)) { (result: TMDBSearchResult) in
                    SearchResultView(title: result.title,
                                     imagePath: result.imagePath,
                                     year: self.yearFromMediaResult(result),
                                     overview: result.overview,
                                     type: result.mediaType,
                                     isAdult: (result as? TMDBMovieSearchResult)?.isAdult)
                }
            }
                .navigationBarTitle(Text("Add Movie"), displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    // FIXME: After dimissing, the view cannot be opened again
                    self.isPresented?.value = false
                }, label: {
                    Text("Cancel")
                }))
        }
    }
    
    func yearFromMediaResult(_ result: TMDBSearchResult) -> Int? {
        if result.mediaType == .movie {
            if let date = (result as? TMDBMovieSearchResult)?.releaseDate {
                return Calendar.current.component(.year, from: date)
            }
        } else {
            if let date = (result as? TMDBShowSearchResult)?.firstAirDate {
                return Calendar.current.component(.year, from: date)
            }
        }
        
        return nil
    }
}

#if DEBUG
struct AddMediaView_Previews : PreviewProvider {
    static var previews: some View {
        AddMediaView()
    }
}
#endif
