// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct DefaultMediaListsSection: View {
    @Binding var selectedMediaObjects: Set<Media>
    @State private var isShowingProPopup: Bool = false

    @FetchRequest(fetchRequest: PredicateMediaList.problems.buildFetchRequest())
    private var problemsMedias: FetchedResults<Media>
    private var problemsMediasCount: Int {
        problemsMedias.filter(PredicateMediaList.problems.customFilter ?? { _ in true }).count
    }

    @FetchRequest(fetchRequest: PredicateMediaList.newSeasons.buildFetchRequest())
    private var newSeasonsMedias: FetchedResults<Media>
    private var newSeasonsMediasCount: Int {
        newSeasonsMedias.filter(PredicateMediaList.newSeasons.customFilter ?? { _ in true }).count
    }

    @FetchRequest(fetchRequest: PredicateMediaList.upcoming.buildFetchRequest())
    private var upcomingMedias: FetchedResults<Media>
    private var upcomingMediasCount: Int {
        upcomingMedias.filter(PredicateMediaList.upcoming.customFilter ?? { _ in true }).count
    }

    var body: some View {
        Section(Strings.Lists.defaultListsHeader) {
            // MARK: Favorites
            NavigationLink {
                FavoritesMediaList(selectedMediaObjects: $selectedMediaObjects)
            } label: {
                ListRowLabel(list: PredicateMediaList.favorites)
            }

            // MARK: Watchlist
            NavigationLink {
                WatchlistMediaList(selectedMediaObjects: $selectedMediaObjects)
            } label: {
                ListRowLabel(list: PredicateMediaList.watchlist, iconColor: .blue, symbolRenderingMode: .monochrome)
            }

            // MARK: Problems
            NavigationLink {
                ProblemsMediaList(selectedMediaObjects: $selectedMediaObjects)
            } label: {
                ListRowLabel(list: PredicateMediaList.problems)
                    .badge(problemsMediasCount)
            }

            // MARK: New Seasons
            NavigationLink {
                NewSeasonsMediaList(selectedMediaObjects: $selectedMediaObjects)
            } label: {
                ListRowLabel(
                    list: PredicateMediaList.newSeasons,
                    iconColor: .purple,
                    symbolRenderingMode: .monochrome
                )
                .badge(newSeasonsMediasCount)
            }

            // MARK: Upcoming
            if StoreManager.shared.hasPurchasedPro {
                NavigationLink {
                    UpcomingMediaList(selectedMediaObjects: $selectedMediaObjects)
                } label: {
                    ListRowLabel(
                        list: PredicateMediaList.upcoming,
                        iconColor: .brownIcon,
                        symbolRenderingMode: .multicolor
                    )
                    .badge(upcomingMediasCount)
                }
            } else {
                Button {
                    isShowingProPopup = true
                } label: {
                    HStack {
                        ListRowLabel(list: PredicateMediaList.upcoming)
                        Spacer()
                        Image(systemName: "lock")
                            .foregroundColor(.secondary)
                        NavigationLinkChevron()
                    }
                }
            }
        }
        .deleteDisabled(true)
        .sheet(isPresented: $isShowingProPopup) {
            ProInfoView(showCancelButton: true)
        }
    }
}
