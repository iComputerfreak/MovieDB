//
//  ResultsPageWrapper.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

/// Decodes a page result
protocol PageWrapperProtocol: Decodable {
    associatedtype ObjectWrapper
    var results: [ObjectWrapper] { get set }
    var totalPages: Int { get set }
}

/// Generic results page decoder
struct ResultsPageWrapper<T: Decodable>: PageWrapperProtocol {
    
    var results: [T]
    var page: Int
    var totalPages: Int
    var totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case results
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
}
