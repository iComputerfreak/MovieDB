//
//  LookupView.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import JFSwiftUI
import os.log
import SwiftUI

struct LookupView: View {
    private enum SearchScope: Hashable {
        case library
        case addMedia
    }

    @State private var isLoading = false
    @State private var isShowingProPopup = false
    @State private var internalSearchText: String
    @State private var selectedScope: SearchScope = .library

    private let externalSearchText: Binding<String>?

    init(searchText: Binding<String>? = nil) {
        self.externalSearchText = searchText
        self._internalSearchText = State(initialValue: searchText?.wrappedValue ?? "")
    }

    private var activeSearchText: Binding<String> {
        if let externalSearchText {
            externalSearchText
        } else {
            $internalSearchText
        }
    }

    private var trimmedSearchText: String {
        activeSearchText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        LoadingView(isShowing: $isLoading) {
            NavigationStack {
                VStack(spacing: 0) {
                    Picker(Strings.Lookup.searchPrompt, selection: $selectedScope) {
                        Text(Strings.TabView.libraryLabel)
                            .tag(SearchScope.library)
                        Text(Strings.AddMedia.navBarTitle)
                            .tag(SearchScope.addMedia)
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
                .searchable(text: activeSearchText, prompt: Text(Strings.Lookup.searchPrompt))
            }
        }
        .sheet(isPresented: $isShowingProPopup) {
            ProInfoView()
        }
    }

    @ViewBuilder
    private var searchContent: some View {
        switch selectedScope {
        case .library:
            LibrarySearchResultsView(searchText: trimmedSearchText) {
                selectedScope = .addMedia
            }
        case .addMedia:
            if trimmedSearchText.count < 3 {
                UnifiedSearchPlaceholderView(
                    title: Strings.AddMedia.navBarTitle,
                    description: Strings.AddMedia.searchPrompt
                )
            } else {
                SearchResultsView(
                    searchText: activeSearchText,
                    selection: .constant(nil),
                    prompt: Text(Strings.Lookup.searchPrompt),
                    showsSearchBar: false
                ) { result in
                    AddMediaSearchRow(result: result) {
                        Task(priority: .userInitiated) {
                            await addMedia(result)
                        }
                    }
                }
            }
        }
    }

    func addMedia(_ result: TMDBSearchResult) async {
        Logger.library.info("Adding \(result.title, privacy: .public) to library")

        await MainActor.run {
            isLoading = true
        }

        do {
            try await MediaLibrary.shared.addMedia(result)
            await MainActor.run {
                isLoading = false
            }
        } catch UserError.mediaAlreadyAdded {
            await MainActor.run {
                isLoading = false
                AlertHandler.showSimpleAlert(
                    title: Strings.AddMedia.Alert.alreadyAddedTitle,
                    message: Strings.AddMedia.Alert.alreadyAddedMessage(result.title)
                )
            }
        } catch UserError.noPro {
            Logger.appStore.warning("User tried adding a media, but reached their pro limit.")
            await MainActor.run {
                isLoading = false
                isShowingProPopup = true
            }
        } catch {
            Logger.general.error("Error loading media: \(error, privacy: .public)")
            await MainActor.run {
                AlertHandler.showError(
                    title: Strings.AddMedia.Alert.errorLoadingTitle,
                    error: error
                )
                isLoading = false
            }
        }
    }
}

#Preview {
    LookupView()
        .previewEnvironment()
}
