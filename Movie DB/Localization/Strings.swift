//
//  Strings.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

enum Strings {
    static let movie = String(
        localized: "global.strings.movie",
        comment: "A string describing a type of media"
    )
    static let show = String(
        localized: "global.strings.show",
        comment: "A string describing a type of media"
    )
    
    enum Alert {
        static let errorLoadingCoreDataTitle = String(
            localized: "global.alert.errorLoadingCoreData.title",
            comment: "Title of an alert informing the user about an error while loading the app's data"
        )
        static let errorSavingCoreDataTitle = String(
            localized: "global.alert.errorSavingCoreData.title",
            comment: "Title of an alert informing the user about an error during saving"
        )
    }
}
