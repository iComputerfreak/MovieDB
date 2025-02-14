//
//  Strings+Library.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings {
    enum Library {
        enum RowSubtitle {
            static func lastModified(_ date: String) -> String {
                String(
                    localized: "library.list.rowSubtitle.lastModified \(date)",
                    comment: "The subtitle of a library row, showing the last modified date"
                )
            }

            static func watchDate(_ date: String) -> String {
                String(
                    localized: "library.list.rowSubtitle.watchDate \(date)",
                    comment: "The subtitle of a library row, showing the watch date"
                )
            }
        }

        static let menuButtonFilter = String(
            localized: "library.navBar.button.filter",
            comment: "The label of the filter button in the navigation bar's menu"
        )
        static let menuSortingHeader = String(
            localized: "library.navBar.header.sorting",
            comment: "Heading for the sorting direction picker in the library menu"
        )
        static let swipeActionDelete = String(
            localized: "library.list.swipe.delete",
            comment: "The label for the delete swipe action in the library list"
        )
        static let mediaActionReload = String(
            localized: "library.list.swipe.reload",
            comment: "The label for the reload action in the library list or media detail"
        )
        static let mediaActionAddToList = String(
            localized: "library.list.action.addToList",
            comment: "The label for the add to list action in the library list or media detail"
        )
        static func footerTotal(_ objCount: Int) -> String {
            String(
                localized: "library.list.footer.total \(objCount)",
                comment: "The total amount of media items in the library. Shown in the footer below the list."
            )
        }

        static func footer(_ objCount: Int) -> String {
            String(
                localized: "library.list.footer \(objCount)",
                comment: "The total amount of media items currently displayed. Shown in the footer below the list."
            )
        }

        static let movieSymbolName = String(
            localized: "library.list.movieSymbolText",
            comment: "A short text describing a movie (e.g. 'Movie'). Used in the library list beneath the name."
        )
        static let showSymbolName = String(
            localized: "library.list.showSymbolText",
            comment: "A short text describing a tv show (e.g. 'TV'). Used in the library list beneath the name."
        )
        static let detailPlaceholder = String(
            localized: "library.detailPlaceholder",
            comment: "The placeholder text displayed in the detail column of the library view when no media is selected"
        )
        static let searchPlaceholder = String(
            localized: "library.searchPlaceholder",
            comment: "The placeholder text displayed in the search field in the library view"
        )
        static let libraryRowAdultString = String(
            localized: "library.list.adultText",
            comment: "The text that is displayed for adult movies"
        )
        static let menuSelectLabel = String(
            localized: "library.navBar.button.select",
            comment: "The text of the multi-selection button in the library menu"
        )
        static func multiDeleteAlertMessage(count: Int) -> String {
            String(
                localized: "library.alert.multiDelete.message \(count)",
                comment: "The message of the delete multiple medias alert"
            )
        }
        static let multiSelectAll = String(
            localized: "library.navBar.selectAll",
            comment: "The select all button in the library menu"
        )
        static let multiDeselectAll = String(
            localized: "library.navBar.deselectAll",
            comment: "The deselect all button in the library menu"
        )

        enum EmptyState {
            static let noResults = String(
                localized: "library.emptyState.noResults",
                comment: "The headline displayed when the search or filter does not match any items."
            )

            static let nothingHere = String(
                localized: "library.emptyState.nothingHere",
                comment: "The headline displayed when the library is empty."
            )

            static let descriptionNoContent = String(
                localized: "library.emptyState.description.noContent",
                comment: "The description displayed when there are no items in the library yet."
            )

            static let descriptionNoSearchResults = String(
                localized: "library.emptyState.description.noSearchResults",
                comment: "The description displayed when the search does not match any items."
            )

            static let descriptionNoFilterResults = String(
                localized: "library.emptyState.description.noFilterResults",
                comment: "The description displayed when the filter does not match any items."
            )

            static let descriptionNoSearchAndFilterResults = String(
                localized: "library.emptyState.description.noSearchAndFilterResults",
                comment: "The description displayed when the search and filter do not match any items."
            )
        }

        enum Alert {
            static let updateErrorTitle = String(
                localized: "library.alert.errorUpdating.title",
                comment: "Title of an alert informing the user about an error during a media update"
            )
            static func updateErrorMessage(_ mediaTitle: String, _ errorDescription: String) -> String {
                String(
                    localized: "library.alert.errorUpdating.message \(mediaTitle) \(errorDescription)",
                    comment: "The message of an alert informing the user about an error during a media update. The first argument is the title of the media object and the second argument is the error description."
                )
            }
        }
    }
}
