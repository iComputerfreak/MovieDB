//
//  Episode.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

public class Episode: NSObject, NSCoding, NSSecureCoding, Decodable {
    public static var supportsSecureCoding = true
    
    var rawAirDate: String?
    var airDate: Date? {
        guard let rawAirDate else {
            return nil
        }
        return Utils.tmdbUTCDateFormatter.date(from: rawAirDate)
    }

    var episodeNumber: Int
    var name: String
    var overview: String?
    var runtime: Int?
    var seasonNumber: Int
    var imagePath: String?
    
    public required init?(coder: NSCoder) {
        rawAirDate = coder.decodeObject(of: NSString.self, forKey: CodingKeys.rawAirDate.stringValue) as String?
        episodeNumber = coder.decodeInteger(forKey: CodingKeys.episodeNumber.stringValue)
        name = coder.decodeObject(of: NSString.self, forKey: CodingKeys.name.stringValue)! as String
        overview = coder.decodeObject(of: NSString.self, forKey: CodingKeys.overview.stringValue) as String?
        runtime = coder.decodeInteger(forKey: CodingKeys.runtime.stringValue)
        seasonNumber = coder.decodeInteger(forKey: CodingKeys.seasonNumber.stringValue)
        imagePath = coder.decodeObject(of: NSString.self, forKey: CodingKeys.imagePath.stringValue) as String?
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(rawAirDate, forKey: CodingKeys.rawAirDate.stringValue)
        coder.encode(episodeNumber, forKey: CodingKeys.episodeNumber.stringValue)
        coder.encode(name, forKey: CodingKeys.name.stringValue)
        coder.encode(overview, forKey: CodingKeys.overview.stringValue)
        coder.encode(runtime, forKey: CodingKeys.runtime.stringValue)
        coder.encode(seasonNumber, forKey: CodingKeys.seasonNumber.stringValue)
        coder.encode(imagePath, forKey: CodingKeys.imagePath.stringValue)
    }
    
    enum CodingKeys: String, CodingKey {
        case rawAirDate = "air_date"
        case episodeNumber = "episode_number"
        case name
        case overview
        case runtime
        case seasonNumber = "season_number"
        case imagePath = "still_path"
    }
}

@objc(EpisodeTransformer)
class EpisodeTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] {
        super.allowedTopLevelClasses + [Episode.self]
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchivedArrayOfObjects(
            ofClasses: [Episode.self, NSString.self],
            from: data
        )
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let episode = value as? Episode else {
            return nil
        }
        // swiftlint:disable:next force_try
        return try! NSKeyedArchiver.archivedData(withRootObject: episode, requiringSecureCoding: true)
    }
}
