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

struct WatchProviderResult: Decodable {
    let link: String
    let providers: [WatchProviderDummy]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        link = try container.decode(String.self, forKey: .link)
        let dummiesByType: [WatchProvider.ProviderType: [WatchProviderInfoDummy]] = [
            .flatrate: try container.decodeIfPresent([WatchProviderInfoDummy].self, forKey: .flatrate) ?? [],
            .ads: try container.decodeIfPresent([WatchProviderInfoDummy].self, forKey: .ads) ?? [],
            .buy: try container.decodeIfPresent([WatchProviderInfoDummy].self, forKey: .buy) ?? [],
        ]
        self.providers = dummiesByType
            .flatMap { type, dummies in
                dummies.map { infoDummy in
                    WatchProviderDummy(info: infoDummy, type: type)
                }
            }
    }
    
    enum CodingKeys: String, CodingKey {
        case link
        case flatrate
        case ads
        case buy
    }
}

struct WatchProviderInfoDummy: Decodable {
    let id: Int
    let priority: Int
    let imagePath: String?
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "provider_id"
        case priority = "display_priority"
        case imagePath = "logo_path"
        case name = "provider_name"
    }
}
