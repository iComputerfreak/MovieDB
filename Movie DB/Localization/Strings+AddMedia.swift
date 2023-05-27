//
//  Strings+AddMedia.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings {
    enum AddMedia {
        static let navBarTitle = String(
            localized: "addMedia.navBar.title",
            comment: "Navigation bar title of the 'add media' sheet"
        )
        static let navBarButtonClose = String(
            localized: "addMedia.navBar.button.close",
            comment: "The label of the button to dismiss the 'add media' sheet"
        )
        static let detailPlaceholderText = String(
            localized: "addMedia.detail.placeholder",
            comment: "The placeholder text displayed in the detail column of the search results view when no search result is selected"
        )
        static let searchPrompt = String(
            localized: "addMedia.searchPrompt",
            comment: "The prompt text in the search field when adding media."
        )
        
        enum Alert {
            static let alreadyAddedTitle = String(
                localized: "addMedia.alert.alreadyAdded.title",
                comment: "Title of an alert that informs the user that he tried to add a media object twice"
            )
            static func alreadyAddedMessage(_ title: String) -> String {
                String(
                    localized: "addMedia.alert.alreadyAdded.message \(title)",
                    comment: "Title of an alert that informs the user that he tried to add a media object twice. The variable is the media title."
                )
            }

            static let errorLoadingTitle = String(
                localized: "addMedia.alert.errorLoading.title",
                comment: "Title of an alert showing an error message while loading the media"
            )
        }
    }
}
