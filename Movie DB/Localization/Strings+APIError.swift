//
//  Strings+APIError.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

// swiftlint:disable superfluous_disable_command nesting line_length file_length type_body_length

extension Strings {
    enum APIError {
        static let invalidResponse = String(
            localized: "apiError.invalidResponse.description",
            comment: "Description of the TMDb API error that occurs when the server returns an invalid response"
        )
        static let unauthorized = String(
            localized: "apiError.unauthorized.description",
            comment: "Description of the TMDb API error that occurs when the API request is unauthorized due to a misconfigured API key"
        )
        static let invalidPageRange = String(
            localized: "apiError.invalidPageRange.description",
            comment: "Description of the TMDb API error that occurs when the app tries to get search results for an invalid range of pages"
        )
        static let pageOutOfBounds = String(
            localized: "apiError.pageOutOfBounds.description",
            comment: "Description of the TMDb API error that occurs when the app tries to get search results for a page that does not exist"
        )
        static func unknown(_ code: Int) -> String {
            String(
                localized: "apiError.unknown.description \(code) \(HTTPURLResponse.localizedString(forStatusCode: code))",
                comment: "Description of the TMDb API error that occurs when the server returns an unknown response. The first parameter is the status code. The second parameter is the localized response"
            )
        }

        static let updateError = String(
            localized: "apiError.updateError.description",
            comment: "Description of the TMDb API error that occurs during updating of the media objects"
        )
        static func statusNotOk(_ response: HTTPURLResponse) -> String {
            String(
                localized: "apiError.statusNotOk.description \(response.statusCode)",
                comment: "Description of the TMDb API error that occurs when the server returns an unexpected status code. The parameter is the status code"
            )
        }
    }
}
