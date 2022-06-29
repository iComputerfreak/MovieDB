//
//  Strings+Legal.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

import Foundation

extension Strings {
    enum Legal {
        static let navBarTitle = String(
            localized: "legal.navBar.title",
            comment: "The navigation bar title for the legal view"
        )
        static func legalNoticeMail(_ mailAddress: AttributedString) -> String {
            String(
                localized: "legal.legalNotice \(mailAddress)",
                comment: "The legal notice in the legal view. The parameter is the legal e-mail address."
            )
        }

        static func appIconAttribution(_ link: AttributedString) -> String {
            String(
                localized: "legal.appIconAttribution \(link)",
                comment: "The attribution for the app icon. The parameter is the attribution link."
            )
        }
    }
}
