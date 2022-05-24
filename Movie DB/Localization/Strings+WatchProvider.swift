//
//  Strings+WatchProvider.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum WatchProvider {
        static let flatrate = String(
            localized: "detail.watchprovider.flatrate",
            comment: "A type of watch provider (flatrate, ads, buy)"
        )
        static let ads = String(
            localized: "detail.watchprovider.ads",
            comment: "A type of watch provider (flatrate, ads, buy)"
        )
        static let buy = String(
            localized: "detail.watchprovider.buy",
            comment: "A type of watch provider (flatrate, ads, buy)"
        )
    }
}
