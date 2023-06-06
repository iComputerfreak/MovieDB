//
//  AddMediaView.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Combine
import CoreData
import Foundation
import struct JFSwiftUI.LoadingView
import os.log
import SwiftUI

struct AddMediaView: View {
    @State private var library: MediaLibrary = .shared
    @State private var isShowingProPopup = false
    @State private var isLoading = false
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationStack {
                SearchResultsView(selection: .constant(nil), prompt: Text(Strings.AddMedia.searchPrompt)) { result in
                    Button {
                        Task(priority: .userInitiated) {
                            await self.addMedia(result)
                        }
                    } label: {
                        SearchResultRow(result: result)
                    }
                    .foregroundColor(.primary)
                }
                .navigationTitle(Strings.AddMedia.navBarTitle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text(Strings.AddMedia.navBarButtonClose)
                }))
            }
        }
        .sheet(isPresented: $isShowingProPopup) {
            ProInfoView()
        }
    }
    
    func addMedia(_ result: TMDBSearchResult) async {
        Logger.library.info("Adding \(result.title, privacy: .public) to library")
        await MainActor.run {
            self.isLoading = true
        }
        // Add the media object to the library
        do {
            try await library.addMedia(result)
            // Dismiss the AddMediaView on success
            self.presentationMode.wrappedValue.dismiss()
        } catch UserError.mediaAlreadyAdded {
            await MainActor.run {
                AlertHandler.showSimpleAlert(
                    title: Strings.AddMedia.Alert.alreadyAddedTitle,
                    message: Strings.AddMedia.Alert.alreadyAddedMessage(result.title)
                )
            }
        } catch UserError.noPro {
            // If the user tried to add media without having bought Pro, show the popup
            Logger.appStore.warning("User tried adding a media, but reached their pro limit.")
            await MainActor.run {
                self.isShowingProPopup = true
            }
        } catch {
            Logger.general.error("Error loading media: \(error, privacy: .public)")
            AlertHandler.showError(
                title: Strings.AddMedia.Alert.errorLoadingTitle,
                error: error
            )
        }
        await MainActor.run {
            self.isLoading = false
        }
    }
}

struct AddMediaView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
            .sheet(isPresented: .constant(true)) {
                AddMediaView()
            }
    }
}
