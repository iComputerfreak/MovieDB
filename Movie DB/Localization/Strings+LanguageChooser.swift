//
//  Strings+LanguageChooser.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum LanguageChooser {
        static let navBarTitle = String(
            localized: "languageChooser.navBar.title",
            comment: "The navigation bar title for the language chooser view"
        )
        static let loadingText = String(
            localized: "languageChooser.loadingText",
            comment: "Placeholder text to display while loading the available languages in the language chooser onboarding screen"
        )
        
        enum Alert {
            static let errorLoadingTitle = String(
                localized: "languageChooser.alert.errorLoading.title",
                comment: "Title of an alert informing the user about an error while loading the available languages"
            )
        }
    }
}
