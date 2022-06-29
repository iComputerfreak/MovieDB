//
//  Strings+Problems.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum Problems {
        static let navBarTitle = String(
            localized: "problems.navBar.title",
            comment: "The navigation bar title for the problems view"
        )
        static func missingList(_ missing: String) -> String {
            String(
                localized: "problems.list.missingList \(missing)",
                comment: "List of missing information on a media. Shown in the problems view. The argument is the formatted list."
            )
        }

        static let noProblemsText = String(
            localized: "problems.noProblemsText",
            comment: "The text displayed in the problems view when there are no problematic media objects"
        )
    }
}
