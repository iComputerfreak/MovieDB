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
        "Season(id: \(id.padding(toLength: 8)), seasonNumber: \(seasonNumber.padding(toLength: 2)), name: \(name), " +
        "show: \(show?.id?.uuidString ?? "nil"))"
    }
}
