//
//  UnifiedSearchView.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import JFSwiftUI
import Observation
import os.log
import SwiftUI

struct UnifiedSearchView: View {
    @Environment(UnifiedSearchCoordinator.self) private var unifiedSearchCoordinator
    @State private var isLoading = false
    @State private var isShowingProPopup = false

    private var trimmedSearchText: String {
        unifiedSearchCoordinator.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        @Bindable var unifiedSearchCoordinator = unifiedSearchCoordinator

        LoadingView(isShowing: $isLoading) {
            NavigationStack {
                VStack(spacing: 0) {
                    Picker(Strings.Lookup.searchPrompt, selection: $unifiedSearchCoordinator.scope) {
                        Text(Strings.TabView.libraryLabel)
                            .tag(UnifiedSearchScope.library)
                        Text(Strings.AddMedia.navBarTitle)
                            .tag(UnifiedSearchScope.addMedia)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    searchContent
                }
                .navigationTitle(Strings.TabView.lookupLabel)
                .navigationDestination(for: Media.self) { mediaObject in
                    MediaDetail()
                        .environmentObject(mediaObject)
                }
                .searchable(text: $unifiedSearchCoordinator.text, prompt: Text(Strings.Lookup.searchPrompt))
            }
        }
        .sheet(isPresented: $isShowingProPopup) {
            ProInfoView()
        }
    }

    @ViewBuilder
    private var searchContent: some View {
        switch unifiedSearchCoordinator.scope {
        case .library:
            LibrarySearchResultsView(searchText: trimmedSearchText) {
                unifiedSearchCoordinator.scope = .addMedia
            }
        case .addMedia:
            if trimmedSearchText.count < 3 {
                UnifiedSearchPlaceholderView(
                    title: Strings.AddMedia.navBarTitle,
                    description: Strings.AddMedia.searchPrompt
                )
            } else {
                SearchResultsView(
                    searchText: .init(
                        get: { unifiedSearchCoordinator.text },
                        set: { unifiedSearchCoordinator.text = $0 }
                    ),
                    selection: .constant(nil),
                    prompt: Text(Strings.Lookup.searchPrompt),
                    showsSearchBar: false
                ) { result in
                    AddMediaSearchRow(result: result) {
                        await addMedia(result)
                    }
                }
            }
        }
    }

    func addMedia(_ result: TMDBSearchResult) async -> Bool {
        Logger.library.info("Adding \(result.title, privacy: .public) to library")

        await MainActor.run {
            isLoading = true
        }

        do {
            try await MediaLibrary.shared.addMedia(result)
            await MainActor.run {
                isLoading = false
            }
            return true
        } catch UserError.mediaAlreadyAdded {
            await MainActor.run {
                isLoading = false
                AlertHandler.showSimpleAlert(
                    title: Strings.AddMedia.Alert.alreadyAddedTitle,
                    message: Strings.AddMedia.Alert.alreadyAddedMessage(result.title)
                )
            }
            return false
        } catch UserError.noPro {
            Logger.appStore.warning("User tried adding a media, but reached their pro limit.")
            await MainActor.run {
                isLoading = false
                isShowingProPopup = true
            }
            return false
        } catch {
            Logger.general.error("Error loading media: \(error, privacy: .public)")
            await MainActor.run {
                AlertHandler.showError(
                    title: Strings.AddMedia.Alert.errorLoadingTitle,
                    error: error
                )
                isLoading = false
            }
            return false
        }
    }
}

#Preview {
    UnifiedSearchView()
        .previewEnvironment()
}
