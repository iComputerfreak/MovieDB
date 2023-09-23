//
//  Strings+Lookup.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings {
    enum Lookup {
        static func errorLoadingMedia(_ localizedDescription: String) -> String {
            String(
                localized: "lookup.errorLoadingMedia %@",
                comment: "An error message indicating some error while loading a media object. The parameter is the error description."
            )
        }
        
        static let searchPrompt = String(
            localized: "lookup.searchPrompt",
            comment: "The prompt text that is displayed in the search bar in the Lookup view"
        )
        
        enum Alert {
            static let errorLoadingTitle = String(
                localized: "lookup.alert.errorLoading.title",
                comment: "Title of an alert informing the user about an error while loading the media"
            )
        }
    }
}
