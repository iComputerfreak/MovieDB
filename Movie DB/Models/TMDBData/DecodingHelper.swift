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
    let providers: [WatchProvider]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        link = try container.decode(String.self, forKey: .link)
        let flatrateProviders = try container.decodeIfPresent([WatchProviderDummy].self, forKey: .flatrate)?
            .map { WatchProvider(dummy: $0, type: .flatrate) } ?? []
        let adsProviders = try container.decodeIfPresent([WatchProviderDummy].self, forKey: .ads)?
            .map { WatchProvider(dummy: $0, type: .ads) } ?? []
        let buyProviders = try container.decodeIfPresent([WatchProviderDummy].self, forKey: .buy)?
            .map { WatchProvider(dummy: $0, type: .buy) } ?? []
        providers = (flatrateProviders + adsProviders + buyProviders)
    }
    
    enum CodingKeys: String, CodingKey {
        case link
        case flatrate
        case ads
        case buy
    }
}

private struct WatchProviderDummy: Decodable {
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

private extension WatchProvider {
    convenience init(dummy: WatchProviderDummy, type: WatchProvider.ProviderType) {
        self.init(id: dummy.id, type: type, name: dummy.name, imagePath: dummy.imagePath, priority: dummy.priority)
    }
}
