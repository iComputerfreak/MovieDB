//
//  Strings+Problems.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings {
    enum Problems {
        static let navBarTitle = String(
            localized: "problems.navBar.title",
            comment: "The navigation bar title for the problems view"
        )

        static let missingListPrefix = String(
            localized: "problems.list.missingListPrefix",
            comment: "Prefix for the list of missing information on a media. Shown in the problems view."
        )

        static let noProblemsText = String(
            localized: "problems.noProblemsText",
            comment: "The text displayed in the problems view when there are no problematic media objects"
        )
    }
}
