//
//  Strings+Lists.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

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
    }
}
