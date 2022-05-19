//
//  APIError.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.08.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation

extension TMDBAPI.APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return String(
                localized: "apiError.invalidResponse.description",
                comment: "Description of the TMDb API error that occurs when the server returns an invalid response"
            )
        case .unauthorized:
            return String(
                localized: "apiError.unauthorized.description",
                comment: "Description of the TMDb API error that occurs when the API request is unauthorized due to a misconfigured API key"
            )
        case .invalidPageRange:
            return String(
                localized: "apiError.invalidPageRange.description",
                comment: "Description of the TMDb API error that occurs when the app tries to get search results for an invalid range of pages"
            )
        case .pageOutOfBounds:
            return String(
                localized: "apiError.pageOutOfBounds.description",
                comment: "Description of the TMDb API error that occurs when the app tries to get search results for a page that does not exist"
            )
        case .unknown(let code):
            return String(
                localized: "apiError.unknown.description \(code) \(HTTPURLResponse.localizedString(forStatusCode: code))",
                comment: "Description of the TMDb API error that occurs when the server returns an unknown response. The first parameter is the status code. The second parameter is the localized response"
            )
        case .updateError:
            return String(
                localized: "apiError.updateError.description",
                comment: "Description of the TMDb API error that occurs during updating of the media objects"
            )
        case .statusNotOk(let response):
            return String(
                localized: "apiError.statusNotOk.description \(response.statusCode)",
                comment: "Description of the TMDb API error that occurs when the server returns an unexpected status code. The parameter is the status code"
            )
        }
    }
}
