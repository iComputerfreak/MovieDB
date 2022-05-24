//
//  Strings+TabView.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum TabView {
        static let libraryLabel = String(
            localized: "tabView.library.label",
            comment: "The label of the library tab of the main TabView"
        )
        static let lookupLabel = String(
            localized: "tabView.lookup.label",
            comment: "The label of the lookup tab of the main TabView"
        )
        static let problemsLabel = String(
            localized: "tabView.problems.label",
            comment: "The label of the problems tab of the main TabView"
        )
        static let settingsLabel = String(
            localized: "tabView.settings.label",
            comment: "The label of the settings tab of the main TabView"
        )
    }
}
