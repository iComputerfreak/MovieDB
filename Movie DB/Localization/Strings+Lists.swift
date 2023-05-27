//
//  Strings+Lists.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

extension Strings {
    enum Lists {
        enum Alert {
            static let newDynamicListTitle = String(
                localized: "lists.alerts.newList.dynamic.title",
                comment: "The title of an alert prompting the user for the name of a new dynamic list"
            )
            static let newCustomListTitle = String(
                localized: "lists.alerts.newList.custom.title",
                comment: "The title of an alert prompting the user for the name of a new custom list"
            )
            static let newListMessage = String(
                localized: "lists.alerts.newList.message",
                comment: "The message of an alert prompting the user for the name of a new media list"
            )
            static let newListButtonAdd = String(
                localized: "lists.alerts.newList.buttons.add",
                comment: "The confirmation button of an alert prompting the user for the name of a new media list. The button creates the new list."
            )
            
            static let alreadyExistsTitle = String(
                localized: "lists.alerts.alreadyExists.title",
                comment: "The message of an alert informing the user that the name of a new media list already exists"
            )
            static func alreadyExistsMessage(_ name: String) -> String {
                String(
                    localized: "lists.alerts.alreadyExists.message \(name)",
                    comment: "The message of an alert informing the user that the name of a new media list already exists"
                )
            }
        }
        
        static let editingInformationHeader = String(
            localized: "lists.editing.header.information",
            comment: "The header for the list information (e.g. name, icon) in the editing view for the media lists"
        )
        static let editingNameLabel = String(
            localized: "lists.editing.label.name",
            comment: "The label for the textfield in the list editing view that describes the name of the list"
        )
        static let editingIconLabel = String(
            localized: "lists.editing.label.icon",
            comment: "The label for the textfield in the list editing view that describes the icon of the list"
        )
        static let defaultListsHeader = String(
            localized: "lists.header.defaultLists",
            comment: "The header for the section containing the default lists in the lists view"
        )
        static let dynamicListsHeader = String(
            localized: "lists.header.dynamicLists",
            comment: "The header for the section containing the dynamic lists in the lists view"
        )
        static let customListsHeader = String(
            localized: "lists.header.customLists",
            comment: "The header for the section containing the custom user lists in the lists view"
        )
        static let deleteLabel = String(
            localized: "lists.label.delete",
            comment: "The label for the 'delete' swipe action, deleting a media list"
        )
        static let removeMediaLabel = String(
            localized: "lists.label.remove",
            comment: "The label for the 'remove' swipe action, removing a media object from a list"
        )
        static let newListLabel = String(
            localized: "lists.label.newList",
            comment: "The label for menu button that shows a menu, prompting the user to choose a type of list to create"
        )
        static let newDynamicListLabel = String(
            localized: "lists.new.label.dynamicList",
            comment: "The label for menu button that shows an alert to create a new dynamic list"
        )
        static let newCustomListLabel = String(
            localized: "lists.new.label.customList",
            comment: "The label for menu button that shows an alert to create a new custom, user list"
        )
        static let filteredListResetWarning = String(
            localized: "lists.filterResetWarning",
            comment: "The warning showed in a filtered list when the filter is reset and thus the list is showing all media objects"
        )
        static let filteredListEmptyMessage = String(
            localized: "lists.filteredListEmpty.message",
            comment: "The message showed in a filtered list when the list is empty"
        )
        static let defaultListNameFavorites = String(
            localized: "lists.defaultListName.favorites",
            comment: "The name of the default 'favorites' list"
        )
        static let defaultListNameWatchlist = String(
            localized: "lists.defaultListName.watchlist",
            comment: "The name of the default 'watchlist' list"
        )
        static let defaultListNameProblems = String(
            localized: "lists.defaultListName.problems",
            comment: "The name of the default 'problems' list"
        )
        static let defaultListNameNewSeasons = String(
            localized: "lists.defaultListName.newSeasons",
            comment: "The name of the default 'New Seasons' list"
        )
        static let watchlistRowLabelWatchlistStateWatched = String(
            localized: "lists.watchlist.watchState.watched",
            comment: "The label of movies in library rows that have been watched."
        )
        static let watchlistRowLabelWatchlistStatePartiallyWatched = String(
            localized: "lists.watchlist.watchState.partiallyWatched",
            comment: "The label of movies in library rows that have been watched partially."
        )
        static let watchlistRowLabelWatchlistStateNotWatched = String(
            localized: "lists.watchlist.watchState.notWatched",
            comment: "The label of movies or shows in library rows that have not been watched yet."
        )
        
        static func watchlistRowLabelWatchlistStateSeason(season: Int) -> String {
            String(
                localized: "lists.watchlist.watchState.watchedSeason \(season)",
                comment: "The label of shows in library rows where up to a specific season has been watched. The first argument is the season."
            )
        }
        
        static func watchlistRowLabelWatchlistStateSeasonOfMax(season: Int, maxSeason: Int) -> String {
            String(
                localized: "lists.watchlist.watchState.watchedSeasonOfMax \(season) \(maxSeason)",
                comment: "The label of shows in library rows where up to a specific season has been watched, but there are further seasons available. The first argument is the season up to which has been watched. The second argument is the number of seasons available."
            )
        }
        
        static func watchlistRowLabelWatchlistStateSeasonEpisode(season: Int, episode: Int) -> String {
            String(
                localized: "lists.watchlist.watchState.watchedSeasonEpisode \(season) \(episode)",
                comment: "The label of shows in watchlist rows where up to a specific season and episode has been watched. The first argument is the season, the second argument is the episode."
            )
        }
        
        static let detailPlaceholderText = String(
            localized: "lists.detail.placeholder",
            comment: "The placeholder text displayed in the detail column of the lists view when no media is selected."
        )
        
        static let rootPlaceholderText = String(
            localized: "lists.root.placeholder",
            comment: "The placeholder text displayed in the middle column of the lists view when no list is selected."
        )
        
        static let configureListLabel = String(
            localized: "lists.detail.configure",
            comment: "The button label for the toolbar button to configure an opened view."
        )
        
        static let favoritesDescription = String(
            localized: "lists.descriptions.favorites",
            comment: "The description of the favorites list that is displayed to the user when tapping the info button."
        )
        
        static let watchlistDescription = String(
            localized: "lists.descriptions.watchlist",
            comment: "The description of the watchlist list that is displayed to the user when tapping the info button."
        )
        
        static let problemsDescription = String(
            localized: "lists.descriptions.problems",
            comment: "The description of the problems list that is displayed to the user when tapping the info button."
        )
        
        static let newSeasonsDescription = String(
            localized: "lists.descriptions.newSeasons",
            comment: "The description of the new seasons list that is displayed to the user when tapping the info button."
        )
    }
}
