//
//  Tag+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

/// Represents a user specified tag
@objc(Tag)
public class Tag: NSManagedObject {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    public convenience init(name: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
    }
    
    override public var description: String {
        if isFault {
            return "\(String(describing: Self.self))(isFault: true, objectID: \(objectID))"
        } else {
            return "\(String(describing: Self.self))(id: \(id?.uuidString ?? "nil"), name: \(name), " +
            "medias: \(medias.count) objects)"
        }
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
    }
    
    override public func awakeFromFetch() {
        super.awakeFromFetch()
        // Migrate existing tags to use an ID
        if self.id == nil {
            self.id = UUID()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    static func fetchOrCreate(name: String, in context: NSManagedObjectContext) -> Tag {
        let fetchRequest = Self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", Schema.Tag.name.rawValue, name)
        fetchRequest.fetchLimit = 1
        if let tag = try? context.fetch(fetchRequest).first {
            return tag
        } else {
            // Create a new tag
            return Tag(name: name, context: context)
        }
    }
}

extension Collection<Tag> {
    func lexicographicallySorted() -> [Tag] {
        sorted { $0.name.lexicographicallyPrecedes($1.name) }
    }
}
