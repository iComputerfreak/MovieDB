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
import Analytics
import struct JFSwiftUI.LoadingView
import os.log
import SwiftUI

@available(
    *,
    deprecated,
    message: "Use UnifiedSearchView with the Add Media segment. Kept for the legacy add-media sheet flow."
)
struct AddMediaView: View {
    @State private var library: MediaLibrary = .shared
    @State private var isShowingProPopup = false
    @State private var isLoading = false
    let initialSearchText: String
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) private var dismiss

    @available(
        *,
        deprecated,
        message: "Use UnifiedSearchView with the Add Media segment. Kept for the legacy add-media sheet flow."
    )
    init(initialSearchText: String = "") {
        self.initialSearchText = initialSearchText
    }
    
    var prompt: Text {
        Text(Strings.AddMedia.searchPrompt)
    }
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationStack {
                VStack {
                    SearchResultsView(
                        selection: .constant(nil),
                        prompt: prompt,
                        initialSearchText: initialSearchText,
                        autoFocus: true
                    ) { result in
                        Button {
                            Task(priority: .userInitiated) {
                                await self.addMedia(result)
                            }
                        } label: {
                            SearchResultRow()
                                .environmentObject(result)
                        }
                        .foregroundColor(.primary)
                    }
                    .navigationTitle(Strings.AddMedia.navBarTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing: DismissButton())
                }
            }
        }
        .sheet(isPresented: $isShowingProPopup) {
            ProInfoView()
        }
    }
    
    func addMedia(_ result: TMDBSearchResult) async {
        Logger.library.info("Adding \(result.title, privacy: .public) to library")
        // Add the media object to the library
        do {
            await MainActor.run {
                isLoading = false
            }
            try await library.addMedia(result)
            if let mediaType = AnalyticsMediaType(rawValue: result.mediaType.rawValue) {
                AnalyticsService.shared.track(.mediaAdded(mediaType: mediaType))
            }
            await MainActor.run {
                isLoading = false
            }
            // Dismiss the AddMediaView on success
            dismiss()
        } catch UserError.mediaAlreadyAdded {
            await MainActor.run {
                isLoading = false
                AlertHandler.showSimpleAlert(
                    title: Strings.AddMedia.Alert.alreadyAddedTitle,
                    message: Strings.AddMedia.Alert.alreadyAddedMessage(result.title)
                )
            }
        } catch UserError.noPro {
            // If the user tried to add media without having bought Pro, show the popup
            Logger.appStore.warning("User tried adding a media, but reached their pro limit.")
            if let mediaType = AnalyticsMediaType(rawValue: result.mediaType.rawValue) {
                AnalyticsService.shared.track(.mediaAddFailedProLimit(mediaType: mediaType))
            }
            self.isShowingProPopup = true
        } catch {
            Logger.general.error("Error loading media: \(error, privacy: .public)")
            await MainActor.run {
                AlertHandler.showError(
                    title: Strings.AddMedia.Alert.errorLoadingTitle,
                    error: error
                )
                self.isLoading = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        Button {} label: {
            Text(verbatim: "Show Sheet")
        }
    }
        .sheet(isPresented: .constant(true)) {
            AddMediaView()
                .previewEnvironment()
        }
}
