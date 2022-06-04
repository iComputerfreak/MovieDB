//
//  List+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MediaList)
public class MediaList: NSManagedObject, MediaListProtocol {
    func buildPredicate() -> NSPredicate {
        // TODO: Replace with predicate from filter settings
        return NSPredicate()
    }
}
