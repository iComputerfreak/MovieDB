//
//  AddMediaView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import CoreData
import struct JFSwiftUI.LoadingView

struct AddMediaView : View {
    
    @ObservedObject private var library = MediaLibrary.shared
    @State private var results: [TMDBSearchResult] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationView {
                VStack {
                    // FIX: For SOME reason, calling searchMedia() inside onCommit crashes the app. We have to call it from a button
                    SearchBar(searchText: $searchText, onCommit: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            searchMedia()
                        }
                    })
                    
                    List {
                        ForEach(self.results) { (result: TMDBSearchResult) in
                            Button(action: { addMedia(result) }) {
                                SearchResultView(result: result)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.vertical)
                .navigationTitle(Text("Add Media"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: { Image(systemName: "xmark") }))
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func searchMedia() {
        print("Search: \(self.searchText)")
        guard !self.searchText.isEmpty else {
            self.results = []
            return
        }
        let api = TMDBAPI.shared
        api.searchMedia(self.searchText, includeAdult: JFConfig.shared.showAdults) { (results: [TMDBSearchResult]?, error: Error?) in
            
            if let error = error {
                print("Error searching for media with searchText '\(self.searchText)': \(error)")
                AlertHandler.showSimpleAlert(title: NSLocalizedString("Error searching"), message: NSLocalizedString("Error performing search: \(error.localizedDescription)"))
                return
            }
            
            guard let results = results else {
                print("Error searching for media with searchText '\(self.searchText)'")
                return
            }
                
            var filteredResults = results
            
            // Filter out adult media from the search results
            if !JFConfig.shared.showAdults {
                filteredResults = results.filter { (searchResult: TMDBSearchResult) in
                    // Only movie search results contain the adult flag
                    if let movieResult = searchResult as? TMDBMovieSearchResult {
                        return !movieResult.isAdult
                    }
                    return true
                }
            }
            // Remove search results with the same TMDB ID
            let duplicates = Dictionary(grouping: filteredResults, by: \.id).filter({ $0.value.count > 1 }).flatMap({ $0.value.dropFirst() })
            for duplicate in duplicates {
                // Delete duplicates from last to first
                let index = filteredResults.lastIndex(where: { $0.id == duplicate.id })
                filteredResults.remove(at: index!)
            }
            DispatchQueue.main.async {
                self.results = filteredResults
            }
        }
    }
    
    func addMedia(_ result: TMDBSearchResult) {
        print("Selected \(result.title)")
        let existingFetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        existingFetchRequest.predicate = NSPredicate(format: "%K = %@", "tmdbID", String(result.id))
        existingFetchRequest.fetchLimit = 1
        let existingObjects = (try? managedObjectContext.count(for: existingFetchRequest)) ?? 0
        if existingObjects > 0 {
            // Already added
            AlertHandler.showSimpleAlert(title: NSLocalizedString("Already Added"), message: NSLocalizedString("You already have '\(result.title)' in your library."))
        } else {
            self.isLoading = true
            TMDBAPI.shared.fetchMediaAsync(id: result.id, type: result.mediaType, context: PersistenceController.viewContext) { (media: Media?, error: Error?) in
                
                if let error = error as? LocalizedError {
                    print("Error loading media: \(error)")
                    DispatchQueue.main.async {
                        AlertHandler.showSimpleAlert(title: NSLocalizedString("Error"), message: NSLocalizedString("Error loading media: \(error.localizedDescription)"))
                    }
                    self.isLoading = false
                    return
                } else if error != nil || media == nil {
                    print("Unknown Error: \(String(describing: error))")
                    assertionFailure("This error should be captured specifically to give the user a more precise error message.")
                    DispatchQueue.main.async {
                        AlertHandler.showSimpleAlert(title: NSLocalizedString("Error"), message: NSLocalizedString("There was an error loading the media."))
                    }
                    self.isLoading = false
                    return
                }
                
                // We don't have to do anything with the media object, since it already was added to the background context and the background context was saved.
                // The object will automatically be merged with the viewContext.
                DispatchQueue.main.async {
                    if let mainMedia = PersistenceController.viewContext.object(with: media!.objectID) as? Media {
                        // Call it on the media object in the viewContext, not on the mediaObject in the background context
                        mainMedia.loadThumbnailAsync()
                    } else {
                        print("Media object does not exist in the viewContext yet. Cannot load thumbnail.")
                    }
                    self.isLoading = false
                    self.presentationMode.wrappedValue.dismiss()
                }
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
        AddMediaView()
            .preferredColorScheme(.dark)
    }
}
#endif
