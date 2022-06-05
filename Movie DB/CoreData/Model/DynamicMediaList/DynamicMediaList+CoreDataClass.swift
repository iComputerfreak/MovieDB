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

@objc(DynamicMediaList)
public class DynamicMediaList: NSManagedObject, MediaListProtocol {
    func buildPredicate() -> NSPredicate {
        filterSetting?.buildPredicate() ?? NSPredicate(value: true)
    }
}
