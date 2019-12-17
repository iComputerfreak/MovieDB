//
//  ResultsPageWrapper.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct ResultsPageWrapper<T>: Codable where T: Codable {
    
    var results: [T]
    var page: Int
    var totalPages: Int
    var totalResults: Int
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//    }
//
//    func encode(to encoder: Encoder) throws {
//
//    }
    
    enum CodingKeys: String, CodingKey {
        case results
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
}
