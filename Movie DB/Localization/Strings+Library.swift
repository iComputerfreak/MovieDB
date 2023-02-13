//
//  Strings+Library.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum Library {
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
            localized: "library.list.movieSymbol",
            comment: "A SF Symbols name describing a movie (e.g. 'm.square'). Used in the library list beneath the name."
        )
        static let showSymbolName = String(
            localized: "library.list.showSymbol",
            comment: "A SF Symbols name describing a series/tv show (e.g. 's.square'). Used in the library list beneath the name."
        )
        static let detailPlaceholder = String(
            localized: "library.detailPlaceholder",
            comment: "The placeholder text displayed in the detail column of the library view when no media is selected"
        )
        static let searchPlaceholder = String(
            localized: "library.searchPlaceholder",
            comment: "The placeholder text displayed in the search field in the library view"
        )
        
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
