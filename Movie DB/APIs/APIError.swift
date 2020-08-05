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
            case .unknown(let code):
                return "HTTP Error \(code): \(HTTPURLResponse.localizedString(forStatusCode: code))"
            case .noTMDBID(let mediaID):
                return "Media \(mediaID) does not have a TMDB ID."
        }
    }
    
}
