//
//  Strings+Lookup.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings {
    enum Lookup {
        enum Alert {
            static let errorLoadingTitle = String(
                localized: "lookup.alert.errorLoading.title",
                comment: "Title of an alert informing the user about an error while loading the media"
            )
        }
    }
}
