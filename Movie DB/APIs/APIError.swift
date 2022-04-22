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
            return "The request returned invalid data."
        case .unauthorized:
            return "API call unauthorized. Invalid API key."
        case .invalidPageRange:
            return "Invalid range of pages. Please specify a valid range."
        case .pageOutOfBounds:
            return "Requested page is out of bounds"
        case .unknown(let code):
            return "HTTP Error \(code): \(HTTPURLResponse.localizedString(forStatusCode: code))"
        case .updateError(reason: let reason):
            return "Error updating the media. \(reason)"
        case .statusNotOk(let response):
            return "Error executing request. HTTP Reponse code \(response.statusCode)."
        }
    }
}
