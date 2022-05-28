//
//  TMDBDataHelpers.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

extension TMDBData {
    enum TMDBDataError: Error {
        case noDecodingContext
    }
    
    enum GenericResultsCodingKeys: String, CodingKey {
        case results
    }
    
    enum KeywordsCodingKeys: String, CodingKey {
        case keywords
        case showKeywords = "results"
    }
    
    enum TranslationsCodingKeys: String, CodingKey {
        case translations
    }
    
    // Is directly mapped to the language when decoding
    struct Translation: Codable, Hashable {
        var language: String
        
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case language = "english_name"
        }
    }
    
    // Is directly mapped to the keyword when decoding
    struct Keyword: Codable, Hashable {
        var keyword: String
        
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case keyword = "name"
        }
    }
    
    struct Creator: Decodable {
        let id: Int?
        let creditID: String?
        let name: String
        let gender: Int?
        let profilePath: String?
        
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case id
            case creditID = "credit_id"
            case name
            case gender
            case profilePath = "profile_path"
        }
    }
    
    struct ProductionCountry: Decodable {
        let iso3166: String
        let name: String?
        
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case iso3166 = "iso_3166_1"
            case name
        }
    }
}
