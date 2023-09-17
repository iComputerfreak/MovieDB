//
//  Strings+UserError.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

extension Strings {
    enum UserError {
        static let noPro = String(
            localized: "userError.noPro",
            comment: "The error message description when a user tries to add a media or access content without having bought pro."
        )
        
        static let mediaAlreadyAdded = String(
            localized: "userError.mediaAlreadyAdded",
            comment: "The error message description when a user tries to add a media that is already in the library."
        )
    }
}
