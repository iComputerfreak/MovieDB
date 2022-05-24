//
//  Strings+MediaSearch.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum MediaSearch {
        static let loading = String(
            localized: "mediaSearch.loading",
            comment: "Placeholder text to show while the data is loading"
        )
        static let noResults = String(
            localized: "mediaSearch.noResults",
            comment: "Text indicating that the search yielded no results."
        )
        static let errorText = String(
            localized: "mediaSearch.errorText",
            comment: "Text indicating that there was an error loading the search results"
        )
        static let loadMore = String(
            localized: "mediaSearch.loadMore",
            comment: "The button label to load more search results"
        )
        
        enum Alert {
            static let errorSearchingTitle = String(
                localized: "mediaSearch.alert.error.title",
                comment: "Title of an alert reporting an error during the search of a media object"
            )
        }
    }
}
