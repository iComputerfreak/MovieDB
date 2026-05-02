// Copyright © 2022 Jonas Frey. All rights reserved.

import Analytics
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
                // This stack is needed, as otherwise the searchContent where the toolbar is attached to is replaced
                // during the animation, cancelling it.
                HStack {
                    searchContent
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker(Strings.Lookup.searchPrompt, selection: $unifiedSearchCoordinator.scope) {
                            Text(Strings.TabView.libraryLabel)
                                .tag(UnifiedSearchScope.library)
                            Text(Strings.AddMedia.navBarTitle)
                                .tag(UnifiedSearchScope.addMedia)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)
                    }
                }
                .navigationDestination(for: Media.self) { mediaObject in
                    MediaDetail()
                        .environmentObject(mediaObject)
                }
                .toolbarTitleDisplayMode(.inline)
                .searchable(text: $unifiedSearchCoordinator.text, prompt: Text(Strings.Lookup.searchPrompt))
                .searchPresentationToolbarBehavior(.avoidHidingContent)
            }
        }
        .sheet(isPresented: $isShowingProPopup) {
            ProInfoView(source: .addMediaLimit)
        }
        .onAppear {
            AnalyticsService.shared.track(.screenViewed(screenName: .lookup))
            if unifiedSearchCoordinator.scope == .addMedia {
                AnalyticsService.shared.track(.screenViewed(screenName: .addMedia))
            }
        }
        .onChange(of: unifiedSearchCoordinator.scope) { _, newValue in
            if newValue == .addMedia {
                AnalyticsService.shared.track(.screenViewed(screenName: .addMedia))
            }
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
                ScreenUnavailableView(
                    title: Strings.AddMedia.navBarTitle,
                    systemImage: "magnifyingglass",
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
            AnalyticsService.shared.track(.mediaAdded(mediaType: result.mediaType.analyticsValue))
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
            AnalyticsService.shared.track(.mediaAddFailedProLimit(mediaType: result.mediaType.analyticsValue))
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
