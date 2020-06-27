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
    @Binding var newMediaBinding: Media?
    @State private var isFetchingMediaToAdd: Bool = false
        
    @Environment(\.presentationMode) private var presentationMode
    
    init(newMedia: Binding<Media?>) {
        self._newMediaBinding = newMedia
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: {
                    print("Search: \(self.searchText)")
                    guard !self.searchText.isEmpty else {
                        self.results = []
                        return
                    }
                    let api = TMDBAPI.shared
                    api.searchMedia(self.searchText, includeAdult: JFConfig.shared.showAdults) { (results: [TMDBSearchResult]?) in
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
                                AlertHandler.showSimpleAlert(title: "Already added", message: "You already have '\(result.title)' in your library.")
                            } else {
                                // TODO: Show an activity indicator here, while adding
                                self.isFetchingMediaToAdd = true
                                DispatchQueue.global(qos: .userInitiated).async {
                                    let media = TMDBAPI.shared.fetchMedia(id: result.id, type: result.mediaType)
                                    guard media != nil else {
                                        // Error loading the media object
                                        AlertHandler.showSimpleAlert(title: "Error loading media", message: "The media could not be loaded. Please try again later.")
                                        return
                                    }
                                    // Save before adding the media
                                    DispatchQueue.global().async {
                                        self.library.save()
                                    }
                                    sleep(20)
                                    DispatchQueue.main.async {
                                        self.library.mediaList.append(media!)
                                        // Go into the Detail View
                                        self.newMediaBinding = media
                                        self.isFetchingMediaToAdd = false
                                        // Only dismiss, if the media was added successfully
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }) {
                            SearchResultView(result: result)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle(Text("Add Movie"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .overlay(
            ZStack {
                Rectangle()
                    // If the rectangle is completely clear, touches will go through
                    .fill(Color(.sRGB, white: 1.0, opacity: Double.leastNonzeroMagnitude))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .disabled(true)
                ProgressView("Loading...")
                    .padding(40)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.systemBackground).shadow(color: Color.gray, radius: 3))
            }
            .hidden(condition: !self.isFetchingMediaToAdd)
        )
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
        AddMediaView(newMedia: .constant(nil))
            .preferredColorScheme(.dark)
    }
}
#endif
