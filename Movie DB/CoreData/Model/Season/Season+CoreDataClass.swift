//
//  Season+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation

/// Represents a season of a show
@objc(Season)
public class Season: NSManagedObject {
    override public var description: String {
        if isFault {
            return "\(String(describing: Self.self))(isFault: true, objectID: \(objectID))"
        } else {
            return "\(String(describing: Self.self))(id: \(id.padding(toLength: 8)), " +
            "seasonNumber: \(seasonNumber.padding(toLength: 2)), name: \(name), show: \(show?.id?.uuidString ?? "nil"))"
        }
    }
}
