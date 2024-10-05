//
//  TMDBDataHelpers.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

// swiftlint:disable nesting

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
        var language: String?
        
        enum CodingKeys: String, CodingKey {
            case language = "english_name"
        }
    }
    
    // Is directly mapped to the keyword when decoding
    struct Keyword: Codable, Hashable {
        var keyword: String
        
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
        
        enum CodingKeys: String, CodingKey {
            case id
            case creditID = "credit_id"
            case name
            case gender
            case profilePath = "profile_path"
        }
    }
    
    /// Represents a crew member decoded from the `/credits` api call
    struct CrewMemberDummy: Decodable {
        let isAdult: Bool?
        let gender: Gender?
        let knownForDepartment: String?
        let name: String
        let originalName: String
        let popularity: Double?
        let imagePath: String?
        let creditID: String?
        let department: String?
        let job: String?
        
        enum Gender: Int, Decodable {
            case unknown = 0
            case female = 1
            case male = 2
            case nonbinary = 3
        }
        
        enum CodingKeys: String, CodingKey {
            case isAdult = "adult"
            case gender
            case knownForDepartment = "known_for_department"
            case name
            case originalName = "original_name"
            case popularity
            case imagePath = "profile_path"
            case creditID = "credit_id"
            case department
            case job
        }
    }
    
    enum CreditsCodingKeys: CodingKey {
        case crew
    }
    
    struct ProductionCountry: Decodable {
        let iso3166: String
        let name: String?
        
        enum CodingKeys: String, CodingKey {
            case iso3166 = "iso_3166_1"
            case name
        }
    }
}

// swiftlint:enable nesting
