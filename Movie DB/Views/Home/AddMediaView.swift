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
    
    private var library = MediaLibrary.shared
    @State private var results: [TMDBSearchResult] = []
    @State private var searchText: String = ""
    @State private var alertShown: Bool = false
    @State private var alertTitle: String? = nil
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchEditingChanged: {
                    print("Search: \(self.searchText)")
                    guard !self.searchText.isEmpty else {
                        self.results = []
                        return
                    }
                    let api = TMDBAPI(apiKey: JFLiterals.apiKey)
                    api.searchMedia(self.searchText) { (results: [TMDBSearchResult]?) in
                        guard let results = results else {
                            print("Error getting results")
                            DispatchQueue.main.async {
                                self.results = []
                            }
                            return
                        }
                        var filteredResults = results
                        // Filter out adult media from the search results
                        if !JFConfig.shared.showAdults {
                             filteredResults = filteredResults.filter { (searchResult: TMDBSearchResult) in
                                // Only movie search results contain the adult flag
                                if let movieResult = searchResult as? TMDBMovieSearchResult {
                                    return !movieResult.isAdult
                                }
                                return true
                            }
                        }
                        DispatchQueue.main.async {
                            self.results = filteredResults
                        }
                    }
                })
                
                List {
                    ForEach(self.results, id: \TMDBSearchResult.id) { (result: TMDBSearchResult) in
                        Button(action: {
                            // Action
                            print("Selected \(result.title)")
                            if self.library.mediaList.contains(where: { $0.tmdbData!.id == result.id }) {
                                // Already added
                                self.alertTitle = result.title
                                self.alertShown = true
                            } else {
                                self.library.mediaList.append(Media.create(from: result))
                            }
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            SearchResultView(result: result)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationBarTitle(Text("Add Movie"), displayMode: .inline)
                .alert(isPresented: $alertShown) {
                    Alert(title: Text("Already added"), message: Text("You already have '\(self.alertTitle ?? "Unknown")' in your library."), dismissButton: .default(Text("Ok")))
            }
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
        Text("Not implemented")
        //AddMediaView()
    }
}
#endif
