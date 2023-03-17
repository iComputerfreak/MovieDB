//
//  Optional+CDColor.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import UIKit

extension CDColor? {
    mutating func update(from uiColor: UIColor?, in managedObjectContext: NSManagedObjectContext) {
        if let uiColor {
            // Update or create
            if let self {
                self.update(from: uiColor)
            } else {
                self = CDColor(context: managedObjectContext, uiColor: uiColor)
            }
        } else {
            // Delete the CDColor, it it's not already nil
            if let self {
                managedObjectContext.delete(self)
            }
            // Invalidate the relationship
            self = nil
        }
    }
}
