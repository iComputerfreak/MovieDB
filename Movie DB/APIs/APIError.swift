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
            return Strings.APIError.invalidResponse
        case .unauthorized:
            return Strings.APIError.unauthorized
        case .invalidPageRange:
            return Strings.APIError.invalidPageRange
        case .pageOutOfBounds:
            return Strings.APIError.pageOutOfBounds
        case let .unknown(code):
            return Strings.APIError.unknown(code)
        case .updateError:
            return Strings.APIError.updateError
        case let .statusNotOk(response):
            return Strings.APIError.statusNotOk(response)
        }
    }
}
