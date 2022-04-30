//
//  WatchProvider.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

public class WatchProvider: NSObject, NSCoding, NSSecureCoding, Decodable {
    public static var supportsSecureCoding = true
    
    let id: Int
    let type: ProviderType
    let name: String
    let imagePath: String?
    let priority: Int
    
    init(id: Int, type: ProviderType, name: String, imagePath: String?, priority: Int) {
        self.id = id
        self.type = type
        self.name = name
        self.imagePath = imagePath
        self.priority = priority
    }
    
    public required init?(coder: NSCoder) {
        id = coder.decodeInteger(forKey: CodingKeys.id.stringValue)
        // swiftlint:disable:next force_cast
        let typeString = coder.decodeObject(forKey: CodingKeys.type.stringValue) as! String
        type = ProviderType(rawValue: typeString)!
        // swiftlint:disable:next force_cast
        name = coder.decodeObject(forKey: CodingKeys.name.stringValue) as! String
        imagePath = coder.decodeObject(forKey: CodingKeys.imagePath.stringValue) as? String
        priority = coder.decodeInteger(forKey: CodingKeys.priority.stringValue)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: CodingKeys.id.stringValue)
        coder.encode(type.rawValue, forKey: CodingKeys.type.stringValue)
        coder.encode(name, forKey: CodingKeys.name.stringValue)
        coder.encode(imagePath, forKey: CodingKeys.imagePath.stringValue)
        coder.encode(priority, forKey: CodingKeys.priority.stringValue)
    }
    
    enum ProviderType: String, Decodable {
        case flatrate
        case ads
        case buy
        
        var capitalized: String { rawValue.capitalized }
        var priority: Int {
            switch self {
            case .flatrate:
                return 10
            case .ads:
                return 5
            case .buy:
                return 0
            }
        }
    }
}

@objc(WatchProviderTransformer)
class WatchProviderTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] {
        super.allowedTopLevelClasses + [WatchProvider.self]
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        // swiftlint:disable:next force_try
        return try! NSKeyedUnarchiver.unarchivedArrayOfObjects(
            ofClasses: [WatchProvider.self, NSString.self],
            from: data
        )
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let providers = value as? [WatchProvider] else {
            return nil
        }
        // swiftlint:disable:next force_try
        return try! NSKeyedArchiver.archivedData(withRootObject: providers, requiringSecureCoding: true)
    }
}
