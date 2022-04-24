//
//  ReleaseDatesHelper.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

struct ReleaseDatesCountry: Decodable {
    let countryCode: String
    let results: [ReleaseDateCertification]
    
    enum CodingKeys: String, CodingKey {
        case countryCode = "iso_3166_1"
        case results = "release_dates"
    }
}

struct ReleaseDateCertification: Decodable {
    let certification: String
    let type: Int
}

struct ContentRatingResult: Decodable {
    let results: [ContentRatingDummy]
}

struct ContentRatingDummy: Decodable {
    let countryCode: String
    let rating: String
    
    enum CodingKeys: String, CodingKey {
        case countryCode = "iso_3166_1"
        case rating
    }
}
