//
//  AddMediaView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import Combine
import struct JFSwiftUI.LoadingView

struct AddMediaView: View {
    @State private var library: MediaLibrary = .shared
    @State private var isShowingProPopup = false
    @State private var isLoading = false
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationView {
                SearchResultsView { result in
                    Button {
                        Task(priority: .userInitiated) {
                            await self.addMedia(result)
                        }
                    } label: {
                        SearchResultRow(result: result)
                    }
                    .foregroundColor(.primary)
                }
                .navigationTitle(Text("Add Media"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    self.dismiss()
                }, label: { Text("Close") }))
            }
        }
        .popover(isPresented: $isShowingProPopup) {
            ProInfoView()
        }
    }
    
    func addMedia(_ result: TMDBSearchResult) async {
        print("Selected \(result.title)")
        // Add the media object to the library
        do {
            try await library.addMedia(result, isLoading: $isLoading)
        } catch UserError.mediaAlreadyAdded {
            await MainActor.run {
                AlertHandler.showSimpleAlert(
                    title: NSLocalizedString(
                        "Already Added",
                        comment: "Title of an alert that informs the user that he tried to add a media object twice"
                    ),
                    message: NSLocalizedString(
                        "You already have '\(result.title)' in your library.",
                        comment: "Title of an alert that informs the user that he tried to add a media object twice. " +
                        "The variable is the media title."
                    )
                )
            }
        } catch UserError.noPro {
            // If the user tried to add media without having bought Pro, show the popup
            self.isShowingProPopup = true
        } catch {
            print("Error loading media: \(error)")
            await MainActor.run {
                AlertHandler.showError(
                    title: NSLocalizedString(
                        "Error Loading Media",
                        comment: "Title of an alert showing an error message while loading the media"
                    ),
                    error: error
                )
                self.isLoading = false
            }
        }
        // Dismiss the AddMediaView
        self.dismiss()
    }
}

struct AddMediaView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .popover(isPresented: .constant(true)) {
                AddMediaView()
            }
    }
}
